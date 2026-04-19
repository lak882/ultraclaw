#!/usr/bin/env python3
"""Platform abstraction for InterClaw.

Centralizes all OS-specific paths and conventions so that individual scripts
remain platform-agnostic.  Every path can be overridden via environment
variables for non-standard installations.

Usage in any script:
    from interclaw_platform import IS_WINDOWS, INTERCLAW_TEMP, IRISPYTHON, ...
"""

import os
import sys
import tempfile

# ---------------------------------------------------------------------------
# OS detection
# ---------------------------------------------------------------------------

IS_WINDOWS = sys.platform == "win32"

# ---------------------------------------------------------------------------
# Temp / runtime directory
# ---------------------------------------------------------------------------
# Linux:   /tmp/interclaw
# Windows: %LOCALAPPDATA%\interclaw  (e.g. C:\Users\<user>\AppData\Local\interclaw)

INTERCLAW_TEMP = os.environ.get("INTERCLAW_TEMP") or (
    os.path.join(os.environ.get("LOCALAPPDATA", tempfile.gettempdir()), "interclaw")
    if IS_WINDOWS
    else "/tmp/interclaw"
)

# ---------------------------------------------------------------------------
# IPC: terminal pool
# ---------------------------------------------------------------------------
# Linux:   Unix domain socket at INTERCLAW_TEMP/terminal.sock
# Windows: TCP loopback on a fixed port (no AF_UNIX on Windows)

POOL_USE_TCP = IS_WINDOWS
POOL_TCP_PORT = int(os.environ.get("INTERCLAW_POOL_PORT", "19881"))

if IS_WINDOWS:
    POOL_SOCKET = ("127.0.0.1", POOL_TCP_PORT)
else:
    POOL_SOCKET = os.path.join(INTERCLAW_TEMP, "terminal.sock")

POOL_PID_FILE = os.path.join(INTERCLAW_TEMP, "terminal.pid")
POOL_LOG_FILE = os.path.join(INTERCLAW_TEMP, "terminal.log")

# ---------------------------------------------------------------------------
# IRIS installation root
# ---------------------------------------------------------------------------
# Auto-detect from irispython binary location or well-known paths.
# Override: IRIS_ROOT environment variable.

_WELL_KNOWN_ROOTS = (
    [
        os.path.join(os.environ.get("PROGRAMFILES", r"C:\Program Files"), "InterSystems", "IRISHealth"),
        os.path.join(os.environ.get("PROGRAMFILES", r"C:\Program Files"), "InterSystems", "IRIS"),
    ]
    if IS_WINDOWS
    else [
        "/usr/local/InterSystems/IRISHealth",
        "/usr/local/InterSystems/IRIS",
        "/opt/intersystems/irishealth",
        "/opt/intersystems/iris",
    ]
)


def _detect_iris_root():
    """Find IRIS install root from irispython or well-known locations."""
    # If running under irispython, the binary itself reveals the root
    exe = sys.executable
    # irispython lives at <root>/bin/irispython[.exe]
    if "irispython" in os.path.basename(exe).lower():
        return os.path.dirname(os.path.dirname(exe))
    # Fall back to well-known locations
    for root in _WELL_KNOWN_ROOTS:
        if os.path.isdir(root):
            return root
    return None


IRIS_ROOT = os.environ.get("IRIS_ROOT") or _detect_iris_root()

# ---------------------------------------------------------------------------
# irispython binary
# ---------------------------------------------------------------------------

_IRISPYTHON_NAME = "irispython.exe" if IS_WINDOWS else "irispython"

IRISPYTHON = os.environ.get("IRISPYTHON") or (
    os.path.join(IRIS_ROOT, "bin", _IRISPYTHON_NAME) if IRIS_ROOT else _IRISPYTHON_NAME
)

# ---------------------------------------------------------------------------
# CSP directory (filedrop base lives here)
# ---------------------------------------------------------------------------
# The deployed InterClaw package lives at ${cspdir}interclaw/.
# On a standard install: <IRIS_ROOT>/csp/interclaw/

CSPDIR = os.environ.get("INTERCLAW_CSPDIR") or (
    os.path.join(IRIS_ROOT, "csp") if IRIS_ROOT else None
)

FILEDROP_BASE = os.environ.get("INTERCLAW_FILEDROP") or (
    os.path.join(CSPDIR, "interclaw", "filedrop") if CSPDIR else None
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def ensure_temp_dir():
    """Create INTERCLAW_TEMP if it doesn't exist."""
    os.makedirs(INTERCLAW_TEMP, exist_ok=True)


def filedrop_path(package, component, subdir="In"):
    """Build a filedrop path: ${cspdir}interclaw/filedrop/<Pkg>/<Component>/<subdir>.

    Args:
        package:   e.g. "StClair.POC"
        component: e.g. "From_EMR"
        subdir:    "In", "Out", or "Files"

    Returns:
        Absolute path string, or raises if FILEDROP_BASE is not set.
    """
    if not FILEDROP_BASE:
        raise RuntimeError(
            "Cannot resolve filedrop path: IRIS_ROOT not detected. "
            "Set IRIS_ROOT or INTERCLAW_FILEDROP environment variable."
        )
    return os.path.join(FILEDROP_BASE, package, component, subdir)


def ensure_filedrop(package, component):
    """Create In/, Out/, and Files/ subdirectories for a filedrop component."""
    for sub in ("In", "Out", "Files"):
        os.makedirs(filedrop_path(package, component, sub), exist_ok=True)
