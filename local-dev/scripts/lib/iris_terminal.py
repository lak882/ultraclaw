#!/usr/bin/env python3
"""WebSocket terminal client for InterSystems IRIS.

Executes ObjectScript code on the server via the Atelier WebSocket terminal API.
Supports persistent connections (keep terminal open between commands) and
multiple concurrent terminals.

Protocol (from vscode-objectscript/src/commands/webSocketTerminal.ts):
    Connect -> recv {"type":"init"} -> send {"type":"config","namespace":ns,"rawMode":false}
    -> recv {"type":"prompt"} -> send {"type":"prompt","input":"command"}
    -> recv {"type":"output","text":"..."} -> recv {"type":"prompt"} (ready for next)

Usage as CLI:
    # Single command (opens, runs, closes)
    iris_terminal.py --server myserver --ns %SYS --code 'write $zversion,!'

    # Run a .cos script file
    iris_terminal.py --server myserver --ns HSLIB --file script.cos

    # Pipe from stdin
    echo 'write 1+1,!' | iris_terminal.py --server myserver --ns %SYS --stdin

    # Raw output (no formatting)
    iris_terminal.py --server myserver --ns %SYS --code 'write $zversion,!' --raw

Usage as library:
    from iris_terminal import IrisTerminal

    # Single command (lazy connect, auto-close when done)
    term = IrisTerminal("myserver", "%SYS")
    result = term.execute('write $zversion,!')
    term.close()

    # Keep connection open for multiple commands (context manager)
    with IrisTerminal("myserver", "HSLIB") as term:
        result1 = term.execute('set x = 1')
        result2 = term.execute('write x,!')  # same session, x is still set

    # Multiple terminals
    term1 = IrisTerminal("myserver", "HSLIB")
    term2 = IrisTerminal("myserver", "%SYS")  # different namespace
    with term1, term2:
        r1 = term1.execute('write $namespace,!')
        r2 = term2.execute('write $namespace,!')
"""

import argparse
import base64
import json
import os
import re
import select
import socket
import struct
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from iris_api import load_servers, resolve_password


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

DEFAULT_TIMEOUT = 120
_HANDSHAKE_TIMEOUT = 10
_INIT_TIMEOUT = 10
_ANSI_RE = re.compile(r"\x1b\[[0-9;]*[a-zA-Z]")


# ---------------------------------------------------------------------------
# WebSocket framing (RFC 6455) -- stdlib only, no external deps
# ---------------------------------------------------------------------------

def _recv_exact(sock, n):
    """Read exactly *n* bytes from a socket.

    Raises ConnectionError if the peer closes before *n* bytes arrive.
    """
    data = b""
    while len(data) < n:
        chunk = sock.recv(n - len(data))
        if not chunk:
            raise ConnectionError("Connection closed while reading")
        data += chunk
    return data


def _ws_connect(host, port, path, credentials, use_ssl=False, timeout=10):
    """Perform the HTTP Upgrade handshake and return the raw socket."""
    ws_key = base64.b64encode(os.urandom(16)).decode()

    handshake = (
        f"GET {path} HTTP/1.1\r\n"
        f"Host: {host}:{port}\r\n"
        f"Upgrade: websocket\r\n"
        f"Connection: Upgrade\r\n"
        f"Sec-WebSocket-Key: {ws_key}\r\n"
        f"Sec-WebSocket-Version: 13\r\n"
        f"Authorization: Basic {credentials}\r\n"
        f"\r\n"
    )

    sock = socket.create_connection((host, port), timeout=timeout)

    if use_ssl:
        import ssl
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        sock = ctx.wrap_socket(sock, server_hostname=host)

    sock.sendall(handshake.encode())

    # Read HTTP response headers (may arrive in multiple chunks)
    response = b""
    while b"\r\n\r\n" not in response:
        chunk = sock.recv(4096)
        if not chunk:
            raise ConnectionError("Server closed connection during handshake")
        response += chunk

    status_line = response.split(b"\r\n")[0].decode()
    if "101" not in status_line:
        raise ConnectionError(f"WebSocket upgrade failed: {status_line}")

    return sock


def _ws_read_frame(sock, timeout=30):
    """Read one WebSocket text frame.  Returns the decoded string, or *None* on timeout."""
    ready = select.select([sock], [], [], timeout)
    if not ready[0]:
        return None

    header = _recv_exact(sock, 2)
    opcode = header[0] & 0x0F

    if opcode == 0x08:  # Close frame
        raise ConnectionError("Server sent close frame")

    length = header[1] & 0x7F
    if length == 126:
        length = struct.unpack(">H", _recv_exact(sock, 2))[0]
    elif length == 127:
        length = struct.unpack(">Q", _recv_exact(sock, 8))[0]

    data = _recv_exact(sock, length)
    return data.decode("utf-8", errors="replace")


def _ws_send_frame(sock, payload):
    """Send a masked WebSocket text frame (client->server must be masked per RFC 6455)."""
    payload_bytes = payload.encode("utf-8")
    mask = os.urandom(4)
    masked = bytes(b ^ mask[i % 4] for i, b in enumerate(payload_bytes))

    frame = bytearray([0x81])  # FIN + text opcode
    length = len(payload_bytes)
    if length < 126:
        frame.append(0x80 | length)
    elif length < 65536:
        frame.append(0x80 | 126)
        frame.extend(struct.pack(">H", length))
    else:
        frame.append(0x80 | 127)
        frame.extend(struct.pack(">Q", length))
    frame.extend(mask)
    frame.extend(masked)
    sock.sendall(bytes(frame))


def _ws_send_close(sock):
    """Send a WebSocket close frame with status 1000 (normal closure)."""
    mask = os.urandom(4)
    status = struct.pack(">H", 1000)
    masked = bytes(b ^ mask[i % 4] for i, b in enumerate(status))
    frame = bytearray([0x88, 0x80 | len(status)])
    frame.extend(mask)
    frame.extend(masked)
    try:
        sock.sendall(bytes(frame))
    except OSError:
        pass


# ---------------------------------------------------------------------------
# Terminal protocol helpers
# ---------------------------------------------------------------------------

def _strip_ansi(text):
    """Remove ANSI escape sequences from *text*."""
    return _ANSI_RE.sub("", text)


def _read_message(sock, timeout=30):
    """Read one JSON message from the WebSocket.  Returns a dict, or *None* on timeout."""
    text = _ws_read_frame(sock, timeout=timeout)
    if text is None:
        return None
    text = text.strip()
    if not text:
        return None
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        return {"type": "raw", "text": text}


# ---------------------------------------------------------------------------
# IrisTerminal — persistent, reusable WebSocket terminal
# ---------------------------------------------------------------------------

class IrisTerminal:
    """A persistent WebSocket terminal connection to an IRIS server.

    Supports two usage patterns:

    1. **Context manager** -- connects on enter, disconnects on exit::

        with IrisTerminal("myserver", "HSLIB") as term:
            r1 = term.execute("set x = 42")
            r2 = term.execute("write x,!")

    2. **Lazy connect** -- connects on first ``execute()``, call ``close()`` when done::

        term = IrisTerminal("myserver", "%SYS")
        result = term.execute("write $zversion,!")
        term.close()

    Each instance holds its own socket.  Multiple instances may coexist
    (even to the same server/namespace) and be used from separate threads.
    A single instance is **not** thread-safe -- do not call ``execute()``
    concurrently on the same terminal from multiple threads.
    """

    def __init__(self, server, namespace="%SYS", config_path=None,
                 timeout=DEFAULT_TIMEOUT, raw=False):
        """Create a terminal handle (does **not** connect yet).

        Args:
            server:      Server name as defined in ``config/servers.json``.
            namespace:   Target IRIS namespace (default ``%SYS``).
            config_path: Optional explicit path to ``servers.json``.
            timeout:     Default per-command timeout in seconds.
            raw:         If *True*, preserve ANSI escape codes in output.
        """
        self.server = server
        self.namespace = namespace
        self.config_path = config_path
        self.timeout = timeout
        self.raw = raw

        # Resolved lazily on first connect
        self._host = None
        self._port = None
        self._path = None
        self._credentials = None
        self._use_ssl = False

        # Connection state
        self._sock = None
        self._connected = False
        self._reconnect_attempted = False

    # ------------------------------------------------------------------
    # Context manager
    # ------------------------------------------------------------------

    def __enter__(self):
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
        return False  # do not suppress exceptions

    def __del__(self):
        # Best-effort cleanup if caller forgets close()
        try:
            self.close()
        except Exception:
            pass

    # ------------------------------------------------------------------
    # Connection lifecycle
    # ------------------------------------------------------------------

    def _resolve_server(self):
        """Load server config and cache connection parameters."""
        if self.server is None:
            # No server specified: use localhost via IRIS globals
            from iris_api import get_local_config
            srv, _ = get_local_config()
            ws = srv["webServer"]
        else:
            servers = load_servers(self.config_path)
            if self.server not in servers:
                raise KeyError(
                    f"Server '{self.server}' not found. "
                    f"Available: {', '.join(servers.keys())}"
                )
            srv = servers[self.server]
            ws = srv["webServer"]

        self._host = ws["host"]
        self._port = ws.get("port", 80)
        prefix = ws.get("pathPrefix", "")
        scheme = ws.get("scheme", "http")
        self._use_ssl = scheme == "https"

        username = srv.get("username", "superuser")
        password = resolve_password(self.server or "localhost", srv)
        self._credentials = base64.b64encode(
            f"{username}:{password}".encode()
        ).decode()

        # Terminal endpoint is always under %SYS; namespace is set via
        # the config message after the WebSocket handshake.
        self._path = f"{prefix}/api/atelier/v8/%25SYS/terminal"

    def connect(self):
        """Open the WebSocket and complete the Atelier terminal handshake.

        Safe to call multiple times -- returns immediately if already connected.

        Raises:
            ConnectionError: On handshake failure or unexpected server message.
            KeyError:        If the server name is not in ``servers.json``.
        """
        if self._connected:
            return

        # Resolve server config on first connect
        if self._host is None:
            self._resolve_server()

        self._sock = _ws_connect(
            self._host, self._port, self._path,
            self._credentials, use_ssl=self._use_ssl,
            timeout=min(self.timeout, _HANDSHAKE_TIMEOUT),
        )

        # 1. Read init message
        init = _read_message(self._sock, timeout=_INIT_TIMEOUT)
        if init is None or init.get("type") != "init":
            self._close_socket()
            raise ConnectionError(f"Expected init message, got: {init}")

        # 2. Send config with target namespace
        _ws_send_frame(self._sock, json.dumps({
            "type": "config",
            "namespace": self.namespace,
            "rawMode": False,
        }))

        # 3. Wait for first prompt (signals ready)
        prompt = _read_message(self._sock, timeout=_INIT_TIMEOUT)
        if prompt is None or prompt.get("type") != "prompt":
            self._close_socket()
            raise ConnectionError(
                f"Expected prompt after config, got: {prompt}"
            )

        self._connected = True
        self._reconnect_attempted = False

    def close(self):
        """Gracefully close the WebSocket connection.

        Safe to call multiple times or on an already-closed terminal.
        """
        if self._sock is not None:
            _ws_send_close(self._sock)
            self._close_socket()
        self._connected = False

    def _close_socket(self):
        """Close the raw socket, ignoring errors."""
        if self._sock is not None:
            try:
                self._sock.close()
            except OSError:
                pass
            self._sock = None

    @property
    def connected(self):
        """Whether the terminal is currently connected."""
        return self._connected

    # ------------------------------------------------------------------
    # Command execution
    # ------------------------------------------------------------------

    def execute(self, code, timeout=None):
        """Execute ObjectScript code and return a structured result.

        Multi-line code is split and each non-empty line is sent as a
        separate command within the same terminal session.  Variables set
        by one line persist for subsequent lines (and subsequent calls,
        as long as the connection stays open).

        Automatically logs to the audit trail (best-effort).

        Args:
            code:    ObjectScript code (multi-line OK).
            timeout: Per-command timeout override (seconds).  Falls back to
                     the instance default if *None*.

        Returns:
            A dict with keys:

            - ``output``    -- cleaned command output (str)
            - ``success``   -- *True* if no error was detected
            - ``error``     -- error message string, or *None*
            - ``namespace`` -- the namespace this terminal targets
        """
        if timeout is None:
            timeout = self.timeout

        start = time.time()

        # Lazy connect (or reconnect after drop)
        if not self._connected:
            try:
                self.connect()
            except (ConnectionError, OSError) as exc:
                return {
                    "output": "",
                    "success": False,
                    "error": f"Connection failed: {exc}",
                    "namespace": self.namespace,
                }

        commands = [line for line in code.strip().splitlines() if line.strip()]
        if not commands:
            return {
                "output": "",
                "success": True,
                "error": None,
                "namespace": self.namespace,
            }

        try:
            result = self._send_commands(commands, timeout)
        except (ConnectionError, OSError) as exc:
            # Connection dropped -- try one automatic reconnect
            if not self._reconnect_attempted:
                self._reconnect_attempted = True
                self._close_socket()
                self._connected = False
                try:
                    self.connect()
                    result = self._send_commands(commands, timeout)
                except (ConnectionError, OSError) as retry_exc:
                    result = {
                        "output": "",
                        "success": False,
                        "error": f"Reconnect failed: {retry_exc}",
                        "namespace": self.namespace,
                    }
            else:
                result = {
                    "output": "",
                    "success": False,
                    "error": f"Connection lost: {exc}",
                    "namespace": self.namespace,
                }
        except TimeoutError as exc:
            result = {
                "output": "",
                "success": False,
                "error": str(exc),
                "namespace": self.namespace,
            }

        # Audit log (best-effort)
        try:
            from audit import log_event
            duration_ms = round((time.time() - start) * 1000, 1)
            log_event("terminal",
                      server=self.server,
                      namespace=self.namespace,
                      code=code.strip()[:500],
                      output=result.get("output", "")[:2000],
                      duration_ms=duration_ms,
                      success=result.get("success", False))
        except Exception:
            pass

        return result

    def _send_commands(self, commands, timeout):
        """Send a list of commands and collect output.

        Called internally by ``execute()``.  Assumes the socket is
        connected and ready (a prompt has been received).

        Returns a result dict (same shape as ``execute()``).
        """
        all_output = []

        for cmd in commands:
            _ws_send_frame(self._sock, json.dumps({
                "type": "prompt",
                "input": cmd,
            }))

            # Collect output messages until the next prompt
            while True:
                msg = _read_message(self._sock, timeout=timeout)
                if msg is None:
                    raise TimeoutError(
                        f"Timeout ({timeout}s) waiting for response to: {cmd}"
                    )

                msg_type = msg.get("type")
                if msg_type == "output":
                    all_output.append(msg.get("text", ""))
                elif msg_type == "prompt":
                    break  # ready for next command
                elif msg_type == "error":
                    error_text = msg.get("text", "Unknown server error")
                    return {
                        "output": "".join(all_output),
                        "success": False,
                        "error": error_text,
                        "namespace": self.namespace,
                    }
                elif msg_type == "read":
                    # Server is requesting input (e.g. ObjectScript READ).
                    # Send an empty response to avoid hanging.
                    _ws_send_frame(self._sock, json.dumps({
                        "type": "read",
                        "input": "",
                    }))

        # Successful: reset the reconnect flag so a future drop gets one retry
        self._reconnect_attempted = False

        raw_output = "".join(all_output)
        cleaned = raw_output if self.raw else _strip_ansi(raw_output)
        cleaned = cleaned.replace("\r\n", "\n").strip()

        return {
            "output": cleaned,
            "success": True,
            "error": None,
            "namespace": self.namespace,
        }

    # ------------------------------------------------------------------
    # Convenience helpers
    # ------------------------------------------------------------------

    def execute_or_raise(self, code, timeout=None):
        """Like ``execute()``, but raises on failure instead of returning an error dict.

        Returns:
            The output string (equivalent to ``result["output"]``).

        Raises:
            RuntimeError: If ``success`` is *False*.
        """
        result = self.execute(code, timeout=timeout)
        if not result["success"]:
            raise RuntimeError(result["error"])
        return result["output"]


# ---------------------------------------------------------------------------
# Backward-compatible module-level functions
# ---------------------------------------------------------------------------

def ws_run_objectscript(code, server="myserver", namespace="%SYS",
                        config_path=None, timeout=DEFAULT_TIMEOUT, raw=False):
    """Execute ObjectScript via a one-shot WebSocket terminal session.

    This is the drop-in replacement for the function of the same name in
    ``ws_terminal.py``.  Internally it creates a temporary ``IrisTerminal``,
    executes the code, and closes the connection.

    Args:
        code:        ObjectScript code (multi-line OK).
        server:      Server name from ``config/servers.json``.
        namespace:   IRIS namespace (default ``%SYS``).
        config_path: Optional path to ``servers.json``.
        timeout:     Per-command timeout in seconds.
        raw:         If *True*, include ANSI escape codes in output.

    Returns:
        str: Cleaned command output.

    Raises:
        ConnectionError: WebSocket connection failure.
        TimeoutError:    No response within timeout.
        RuntimeError:    Server-side error.
        KeyError:        Server name not found in config.
    """
    term = IrisTerminal(
        server, namespace,
        config_path=config_path,
        timeout=timeout,
        raw=raw,
    )
    try:
        term.connect()
        result = term.execute(code, timeout=timeout)
    finally:
        term.close()

    if not result["success"]:
        error = result["error"] or "Unknown error"
        if "Timeout" in error:
            raise TimeoutError(error)
        elif "Connection" in error:
            raise ConnectionError(error)
        else:
            raise RuntimeError(error)

    return result["output"]


def ws_run_in_namespace(code, namespace, server_name, config_path=None,
                        timeout=DEFAULT_TIMEOUT, raw=False):
    """Convenience wrapper matching ``iris_terminal.run_in_namespace()`` signature."""
    return ws_run_objectscript(
        code, server=server_name, namespace=namespace,
        config_path=config_path, timeout=timeout, raw=raw,
    )


# ---------------------------------------------------------------------------
# Pool-aware execution — uses persistent daemon when available
# ---------------------------------------------------------------------------

from interclaw_platform import POOL_SOCKET as _POOL_SOCKET, POOL_USE_TCP as _POOL_USE_TCP


def pool_execute(server, namespace, code, timeout=None):
    """Execute via the persistent terminal pool (~2ms) with direct fallback (~125ms).

    Tries the pool daemon first.  If it's not running, falls back to
    a one-shot IrisTerminal connection (same as ws_run_objectscript but
    returns a dict instead of raising).

    Returns:
        dict with keys: output, success, error, namespace
    """
    try:
        if _POOL_USE_TCP:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        else:
            sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(_POOL_SOCKET)
        sock.settimeout((timeout or DEFAULT_TIMEOUT) + 5)
        req = json.dumps({
            "cmd": "execute",
            "server": server,
            "namespace": namespace,
            "code": code,
            "timeout": timeout,
        }) + "\n"
        sock.sendall(req.encode())
        data = b""
        while b"\n" not in data:
            chunk = sock.recv(65536)
            if not chunk:
                break
            data += chunk
        sock.close()
        return json.loads(data.decode().strip())
    except (FileNotFoundError, ConnectionRefusedError, OSError):
        # Pool not running — direct connection
        term = IrisTerminal(server, namespace, timeout=timeout or DEFAULT_TIMEOUT)
        try:
            term.connect()
            return term.execute(code, timeout=timeout)
        except Exception as e:
            return {"output": "", "success": False,
                    "error": str(e), "namespace": namespace}
        finally:
            term.close()


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Run ObjectScript on IRIS via WebSocket terminal (remote)",
    )
    parser.add_argument(
        "--server", "-s", required=True,
        help="Server name from config/servers.json",
    )
    parser.add_argument(
        "--namespace", "-n", "--ns", default="%SYS",
        help="IRIS namespace (default: %%SYS)",
    )
    parser.add_argument("--code", help="ObjectScript code to execute")
    parser.add_argument(
        "--file", "-f", help="File containing ObjectScript code",
    )
    parser.add_argument(
        "--stdin", action="store_true",
        help="Read ObjectScript from stdin",
    )
    parser.add_argument(
        "--timeout", type=int, default=DEFAULT_TIMEOUT,
        help=f"Timeout in seconds (default: {DEFAULT_TIMEOUT})",
    )
    parser.add_argument(
        "--raw", action="store_true",
        help="Show raw output including ANSI codes",
    )
    parser.add_argument(
        "--config", "-c",
        help="Path to servers.json",
    )
    args = parser.parse_args()

    # Determine code source
    if args.code:
        code = args.code
    elif args.file:
        with open(args.file) as f:
            code = f.read()
    elif args.stdin:
        code = sys.stdin.read()
    else:
        parser.error("One of --code, --file, or --stdin is required")

    try:
        output = ws_run_objectscript(
            code,
            server=args.server,
            namespace=args.namespace,
            config_path=args.config,
            timeout=args.timeout,
            raw=args.raw,
        )
        if output:
            print(output)
    except (ConnectionError, RuntimeError, KeyError, TimeoutError) as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
