#!/usr/bin/env python3
"""Persistent terminal sessions for IRIS WebSocket connections.

Keeps IrisTerminal sessions alive between script invocations so each
command takes ~2ms instead of ~125ms.  Scripts call pool_execute() which
talks to this daemon over a Unix socket (Linux) or TCP loopback (Windows).

    Start:   iris_terminal_pool.py --start [--server myserver]
    Stop:    iris_terminal_pool.py --stop
    Status:  iris_terminal_pool.py --status
"""

import json
import os
import signal
import socket
import sys
import threading
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from interclaw_platform import POOL_SOCKET, POOL_PID_FILE, POOL_LOG_FILE, POOL_USE_TCP

SOCKET_PATH = POOL_SOCKET
PID_FILE = POOL_PID_FILE
LOG_FILE = POOL_LOG_FILE


def _create_server_socket():
    """Create the listener socket (AF_UNIX on Linux, TCP loopback on Windows)."""
    if POOL_USE_TCP:
        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        srv.bind(SOCKET_PATH)  # ("127.0.0.1", port)
        return srv
    else:
        os.makedirs(os.path.dirname(SOCKET_PATH), exist_ok=True)
        if os.path.exists(SOCKET_PATH):
            os.unlink(SOCKET_PATH)
        srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        srv.bind(SOCKET_PATH)
        os.chmod(SOCKET_PATH, 0o777)
        return srv


def _create_client_socket():
    """Create a client socket and connect to the pool."""
    if POOL_USE_TCP:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    else:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(SOCKET_PATH)
    return sock


# ---------------------------------------------------------------------------
# Pool — holds live IrisTerminal instances keyed by "server/namespace"
# ---------------------------------------------------------------------------

class TerminalPool:
    def __init__(self):
        self.terminals = {}       # "server/ns" -> IrisTerminal
        self._locks = {}          # "server/ns" -> Lock (one command at a time per terminal)
        self._global = threading.Lock()

    def execute(self, server, namespace, code, timeout=None):
        key = f"{server}/{namespace}"
        term, lock = self._get_or_create(key, server, namespace)
        with lock:
            result = term.execute(code, timeout=timeout)
            if not result["success"] and "Connection" in (result.get("error") or ""):
                # Connection dropped — reconnect and retry once
                try:
                    term.close()
                    term.connect()
                    result = term.execute(code, timeout=timeout)
                except Exception as e:
                    result = {"output": "", "success": False,
                              "error": str(e), "namespace": namespace}
            return result

    def _get_or_create(self, key, server, namespace):
        with self._global:
            if key not in self.terminals:
                from iris_terminal import IrisTerminal
                term = IrisTerminal(server, namespace)
                term.connect()
                self.terminals[key] = term
                self._locks[key] = threading.Lock()
                _log(f"Opened terminal: {key}")
            return self.terminals[key], self._locks[key]

    def sessions(self):
        return list(self.terminals.keys())

    def close_all(self):
        for key, term in self.terminals.items():
            try:
                term.close()
                _log(f"Closed terminal: {key}")
            except Exception:
                pass
        self.terminals.clear()
        self._locks.clear()


# ---------------------------------------------------------------------------
# Server — Unix socket, one thread per client
# ---------------------------------------------------------------------------

def serve(default_server=None):
    pool = TerminalPool()

    srv = _create_server_socket()
    srv.listen(5)

    with open(PID_FILE, "w") as f:
        f.write(str(os.getpid()))

    def shutdown(signum, frame):
        _log("Shutting down")
        pool.close_all()
        srv.close()
        _cleanup()
        os._exit(0)

    signal.signal(signal.SIGTERM, shutdown)
    signal.signal(signal.SIGINT, shutdown)

    def handle(conn):
        try:
            data = b""
            conn.settimeout(300)
            while b"\n" not in data:
                chunk = conn.recv(65536)
                if not chunk:
                    break
                data += chunk

            req = json.loads(data.decode().strip())
            cmd = req.get("cmd")

            if cmd == "ping":
                resp = {"ok": True, "sessions": pool.sessions()}
            elif cmd == "execute":
                resp = pool.execute(
                    req["server"], req["namespace"],
                    req["code"], req.get("timeout"),
                )
            elif cmd == "stop":
                conn.sendall((json.dumps({"ok": True}) + "\n").encode())
                conn.close()
                shutdown(None, None)
                return
            else:
                resp = {"error": f"unknown cmd: {cmd}"}

            conn.sendall((json.dumps(resp) + "\n").encode())
        except Exception as e:
            try:
                conn.sendall((json.dumps({"error": str(e)}) + "\n").encode())
            except Exception:
                pass
        finally:
            try:
                conn.close()
            except Exception:
                pass

    _log(f"Terminal pool listening on {SOCKET_PATH}")

    while True:
        try:
            conn, _ = srv.accept()
            t = threading.Thread(target=handle, args=(conn,), daemon=True)
            t.start()
        except OSError:
            break


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _log(msg):
    ts = time.strftime("%H:%M:%S")
    line = f"[{ts}] {msg}\n"
    try:
        with open(LOG_FILE, "a") as f:
            f.write(line)
    except Exception:
        pass


def _cleanup():
    paths = [PID_FILE]
    if not POOL_USE_TCP:
        paths.insert(0, SOCKET_PATH)
    for path in paths:
        try:
            os.unlink(path)
        except FileNotFoundError:
            pass


def _read_pid():
    try:
        with open(PID_FILE) as f:
            return int(f.read().strip())
    except (FileNotFoundError, ValueError):
        return None


def _is_running():
    pid = _read_pid()
    if pid is None:
        return False
    if POOL_USE_TCP:
        # On Windows, try connecting to the TCP port
        try:
            sock = _create_client_socket()
            sock.close()
            return True
        except (ConnectionRefusedError, OSError):
            return False
    try:
        os.kill(pid, 0)
        return True
    except ProcessLookupError:
        return False


def _send_cmd(cmd_dict):
    """Send a command to the running pool and return the response."""
    sock = _create_client_socket()
    sock.settimeout(10)
    sock.sendall((json.dumps(cmd_dict) + "\n").encode())
    data = b""
    while b"\n" not in data:
        chunk = sock.recv(65536)
        if not chunk:
            break
        data += chunk
    sock.close()
    return json.loads(data.decode().strip())


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    import argparse
    p = argparse.ArgumentParser(description="Persistent IRIS terminal sessions")
    p.add_argument("--start", action="store_true", help="Start the pool daemon")
    p.add_argument("--stop", action="store_true", help="Stop the pool daemon")
    p.add_argument("--status", action="store_true", help="Check pool status")
    p.add_argument("--server", help="Default server to pre-warm")
    p.add_argument("--foreground", action="store_true", help="Run in foreground (don't daemonize)")
    args = p.parse_args()

    if args.stop:
        if not _is_running():
            print("Pool is not running")
            return
        try:
            _send_cmd({"cmd": "stop"})
            print("Pool stopped")
        except Exception:
            pid = _read_pid()
            if pid:
                if POOL_USE_TCP:
                    import subprocess
                    subprocess.run(["taskkill", "/F", "/PID", str(pid)],
                                   capture_output=True)
                    print(f"Killed process {pid}")
                else:
                    os.kill(pid, signal.SIGTERM)
                    print(f"Sent SIGTERM to {pid}")
            _cleanup()

    elif args.status:
        if not _is_running():
            print("Pool is not running")
            sys.exit(1)
        try:
            resp = _send_cmd({"cmd": "ping"})
            sessions = resp.get("sessions", [])
            print(f"Pool is running (pid {_read_pid()})")
            if sessions:
                print(f"Active sessions: {', '.join(sessions)}")
            else:
                print("No active sessions (terminals created on demand)")
        except Exception as e:
            print(f"Pool unreachable: {e}")
            sys.exit(1)

    elif args.start:
        if _is_running():
            print(f"Pool already running (pid {_read_pid()})")
            return

        if args.foreground:
            serve(args.server)
        elif POOL_USE_TCP:
            # Windows: no fork, run in a subprocess
            import subprocess
            proc = subprocess.Popen(
                [sys.executable, __file__, "--start", "--foreground"]
                + (["--server", args.server] if args.server else []),
                stdout=open(LOG_FILE, "a"),
                stderr=subprocess.STDOUT,
                stdin=subprocess.DEVNULL,
                creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
            )
            time.sleep(0.5)
            if proc.poll() is None:
                # Write PID so _is_running() works
                with open(PID_FILE, "w") as f:
                    f.write(str(proc.pid))
                print(f"Terminal pool started (pid {proc.pid})")
            else:
                print(f"Failed to start pool — check {LOG_FILE}")
                sys.exit(1)
        else:
            # Linux: daemonize with double-fork
            pid = os.fork()
            if pid > 0:
                time.sleep(0.3)
                if _is_running():
                    print(f"Terminal pool started (pid {_read_pid()})")
                else:
                    print(f"Failed to start pool — check {LOG_FILE}")
                    sys.exit(1)
                return

            os.setsid()
            pid = os.fork()
            if pid > 0:
                os._exit(0)

            sys.stdin = open(os.devnull, "r")
            sys.stdout = open(LOG_FILE, "a")
            sys.stderr = sys.stdout

            serve(args.server)
    else:
        p.print_help()


if __name__ == "__main__":
    main()
