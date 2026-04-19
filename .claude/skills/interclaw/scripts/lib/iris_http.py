#!/usr/bin/env python3
"""Unified HTTP API client for InterSystems IRIS.

Replaces ~20 thin wrapper scripts with a single file that:
  1. Declares all known endpoints in a machine-readable ENDPOINTS registry
  2. Provides an IrisHTTP class with one method per operation
  3. Exposes a CLI with argparse subcommands

Design:
  - Standard library only (urllib, json, socket, etc.)
  - Imports auth/config helpers from iris_api.py (kept as-is)
  - Returns structured dicts: {"success": bool, "data": ..., "errors": [...]}
  - Handles /goto emission for put_doc
  - Includes TCP/MLLP send from send_hl7

Usage:
  iris_http.py --server myserver --ns HSLIB list-endpoints
  iris_http.py --server myserver --ns HSLIB list-docs --type cls
  iris_http.py --server myserver --ns HSLIB get-doc My.Class.cls
  iris_http.py --server myserver --ns HSLIB put-doc My.Class.cls --input src/file.cls --compile
  iris_http.py --server myserver --ns HSLIB query "SELECT TOP 10 ..."
  iris_http.py --server myserver --ns HSLIB send --url /path --input msg.hl7
  iris_http.py --server myserver --ns HSLIB production status
  iris_http.py --server myserver --ns HSLIB errors --package MyPkg
"""

import argparse
import base64
import fnmatch
import json
import os
import socket
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import (
    AtelierError,
    build_base_url,
    build_interop_url,
    load_servers,
    make_interop_request,
    make_request,
    parse_atelier_response,
    resolve_password,
    set_audit_context,
)
from portal_urls import classify_from_source


# ============================================================================
# Part A: ENDPOINTS registry
# ============================================================================

ENDPOINTS = {
    # ------------------------------------------------------------------
    # Connection & Server Info
    # ------------------------------------------------------------------
    "server-info": {
        "description": "Get server version, platform, and API info",
        "method": "GET",
        "api": "atelier",
        "path_template": "/",
        "params": {},
    },
    "list-namespaces": {
        "description": "List all namespaces on the server",
        "method": "GET",
        "api": "atelier",
        "path_template": "/v1/",
        "params": {},
    },
    "check-namespace": {
        "description": "Check if a namespace is accessible",
        "method": "GET",
        "api": "atelier",
        "path_template": "/v1/{namespace}",
        "params": {},
    },

    # ------------------------------------------------------------------
    # Document Management
    # ------------------------------------------------------------------
    "list-docs": {
        "description": "List documents (classes, routines, includes) in a namespace",
        "method": "GET",
        "api": "atelier",
        "path_template": "/v1/{namespace}/docnames/{type}?generated=0",
        "params": {
            "type": {"description": "Document type: cls, mac, inc, csp", "default": "cls"},
            "filter": {"description": "Glob filter pattern (e.g. 'HS.Hub*')", "default": None},
        },
    },
    "get-doc": {
        "description": "Get a document's source code from the server",
        "method": "GET",
        "api": "atelier",
        "path_template": "/v1/{namespace}/doc/{name}",
        "params": {
            "name": {"description": "Document name (e.g. My.Class.cls)", "required": True},
        },
    },
    "put-doc": {
        "description": "Save a document to the server (create or update)",
        "method": "PUT",
        "api": "atelier",
        "path_template": "/v1/{namespace}/doc/{name}",
        "params": {
            "name": {"description": "Document name (e.g. My.Class.cls)", "required": True},
            "content": {"description": "Document content (list of lines or string)", "required": True},
            "compile": {"description": "Compile after saving", "default": False},
            "force": {"description": "Skip timestamp concurrency check", "default": False},
        },
        "body_template": {"enc": False, "content": []},
    },
    "delete-doc": {
        "description": "Delete a document from the server",
        "method": "DELETE",
        "api": "atelier",
        "path_template": "/v1/{namespace}/doc/{name}",
        "params": {
            "name": {"description": "Document name (e.g. My.Class.cls)", "required": True},
        },
    },
    "compile": {
        "description": "Compile one or more documents",
        "method": "POST",
        "api": "atelier",
        "path_template": "/v1/{namespace}/action/compile",
        "params": {
            "docs": {"description": "List of document names to compile", "required": True},
        },
        "body_template": "list_of_doc_names",
    },
    "compile-async": {
        "description": "Queue an asynchronous compile job via the /work endpoint",
        "method": "POST",
        "api": "atelier",
        "path_template": "/v1/{namespace}/work",
        "params": {
            "docs": {"description": "List of document names to compile", "required": True},
            "flags": {"description": "Compile flags", "default": "cuk"},
        },
        "body_template": {"action": "compile", "docs": [], "flags": "cuk"},
    },
    "compile-async-poll": {
        "description": "Poll status of an async compile job",
        "method": "GET",
        "api": "atelier",
        "path_template": "/v1/{namespace}/work/{job_id}",
        "params": {
            "job_id": {"description": "Job ID returned from compile-async", "required": True},
        },
    },
    "compile-async-delete": {
        "description": "Delete/cancel an async compile job",
        "method": "DELETE",
        "api": "atelier",
        "path_template": "/v1/{namespace}/work/{job_id}",
        "params": {
            "job_id": {"description": "Job ID to delete", "required": True},
        },
    },

    # ------------------------------------------------------------------
    # SQL Queries
    # ------------------------------------------------------------------
    "query": {
        "description": "Execute a SQL query against the IRIS server",
        "method": "POST",
        "api": "atelier",
        "path_template": "/v1/{namespace}/action/query",
        "params": {
            "sql": {"description": "SQL query string", "required": True},
        },
        "body_template": {"query": ""},
    },

    # ------------------------------------------------------------------
    # Code Search
    # ------------------------------------------------------------------
    "search": {
        "description": "Search code on the server (server-side grep)",
        "method": "GET",
        "api": "atelier",
        "api_version": "v2",
        "path_template": "/v2/{namespace}/action/search",
        "params": {
            "query": {"description": "Search string or regex pattern", "required": True},
            "files": {"description": "File pattern filter", "default": "*.cls,*.mac,*.int,*.inc"},
            "regex": {"description": "Treat query as regex", "default": False},
            "case": {"description": "Case-sensitive search", "default": False},
            "sys": {"description": "Include system files", "default": False},
            "gen": {"description": "Include generated files", "default": False},
            "max": {"description": "Maximum results", "default": 100},
        },
    },

    # ------------------------------------------------------------------
    # HL7 Schema Introspection
    # ------------------------------------------------------------------
    "get-schema": {
        "description": "Fetch an HL7 schema XML document (e.g. 2.5.1.HL7)",
        "method": "GET",
        "api": "atelier",
        "path_template": "/v1/{namespace}/doc/{category}.HL7",
        "params": {
            "category": {"description": "Schema category (e.g. 2.5.1)", "required": True},
        },
    },
    "list-schema-categories": {
        "description": "List HL7 schema categories via SQL",
        "method": "POST",
        "api": "atelier",
        "path_template": "/v1/{namespace}/action/query",
        "params": {},
        "body_template": {"query": "SELECT Category, Description, IsStandard FROM EnsLib_HL7.Schema_TypeCategories()"},
    },

    # ------------------------------------------------------------------
    # Production Management (InteropEditors v1+)
    # ------------------------------------------------------------------
    "production-status": {
        "description": "Get the running production name and status",
        "method": "GET",
        "api": "interop-editors",
        "api_version": "v3",
        "path_template": "/productions/status",
        "params": {},
    },
    "production-list": {
        "description": "List all productions in the namespace",
        "method": "GET",
        "api": "interop-editors",
        "api_version": "v1",
        "path_template": "/productions",
        "params": {},
    },
    "production-start": {
        "description": "Start a production",
        "method": "POST",
        "api": "interop-editors",
        "api_version": "v3",
        "path_template": "/productions/state/{name}",
        "params": {
            "name": {"description": "Production class name", "required": True},
            "state": {"description": "State action", "default": "start"},
        },
    },
    "production-stop": {
        "description": "Stop a running production",
        "method": "POST",
        "api": "interop-editors",
        "api_version": "v3",
        "path_template": "/productions/state/{name}",
        "params": {
            "name": {"description": "Production class name", "required": True},
            "state": {"description": "State action", "default": "stop"},
        },
    },
    "production-recover": {
        "description": "Recover a suspended production",
        "method": "POST",
        "api": "interop-editors",
        "api_version": "v3",
        "path_template": "/productions/state/{name}",
        "params": {
            "name": {"description": "Production class name", "required": True},
            "state": {"description": "State action", "default": "recover"},
        },
    },

    # ------------------------------------------------------------------
    # Host Settings (InteropEditors v3)
    # ------------------------------------------------------------------
    "get-settings": {
        "description": "Get all settings for a business host class",
        "method": "GET",
        "api": "interop-editors",
        "api_version": "v3",
        "path_template": "/productions/{production}/{host_type}/{class_name}/settings",
        "params": {
            "production": {"description": "Production class name", "required": True},
            "host_type": {"description": "Host type: service, process, operation", "required": True},
            "class_name": {"description": "Host class name", "required": True},
        },
    },
    "find-productions": {
        "description": "Find available productions in namespace (for settings queries)",
        "method": "GET",
        "api": "interop-editors",
        "api_version": "v1",
        "path_template": "/productions",
        "params": {},
    },

    # ------------------------------------------------------------------
    # DTL (InteropEditors v3)
    # ------------------------------------------------------------------
    "test-dtl": {
        "description": "Test a DTL transformation with a sample message",
        "method": "POST",
        "api": "interop-editors",
        "api_version": "v3",
        "path_template": "/dtl/test/{dtl_class}",
        "params": {
            "dtl_class": {"description": "DTL class name", "required": True},
            "inputMessage": {"description": "HL7 message string for testing", "required": True},
        },
    },

    # ------------------------------------------------------------------
    # Lookup Tables (InteropEditors v1)
    # ------------------------------------------------------------------
    "get-lookup-tables": {
        "description": "List all lookup tables",
        "method": "GET",
        "api": "interop-editors",
        "api_version": "v1",
        "path_template": "/lookup-tables",
        "params": {},
    },

    # ------------------------------------------------------------------
    # Error Checking (via SQL)
    # ------------------------------------------------------------------
    "get-event-log-errors": {
        "description": "Query error/warning events from Ens_Util.Log",
        "method": "POST",
        "api": "atelier",
        "path_template": "/v1/{namespace}/action/query",
        "params": {
            "package": {"description": "Filter by package name prefix", "default": None},
            "count": {"description": "Number of recent errors", "default": 20},
            "since": {"description": "Only show errors since (HH:MM or YYYY-MM-DD)", "default": None},
        },
    },
    "get-errored-messages": {
        "description": "Query errored/suspended messages from Ens.MessageHeader",
        "method": "POST",
        "api": "atelier",
        "path_template": "/v1/{namespace}/action/query",
        "params": {
            "package": {"description": "Filter by package name prefix", "default": None},
            "count": {"description": "Number of recent messages", "default": 20},
            "since": {"description": "Only show since (HH:MM or YYYY-MM-DD)", "default": None},
        },
    },

    # ------------------------------------------------------------------
    # Message Sending (HTTP and TCP/MLLP)
    # ------------------------------------------------------------------
    "send-http": {
        "description": "Send a message (HL7/JSON/XML) to an HTTP service via CSP gateway",
        "method": "POST",
        "api": "raw",
        "path_template": "{url}",
        "params": {
            "url": {"description": "Full URL path with ?CfgItem=", "required": True},
            "content_type": {"description": "Content-Type header", "default": "application/hl7-v2"},
            "body": {"description": "Message body string", "required": True},
        },
    },
    "send-tcp": {
        "description": "Send an HL7 message via TCP/MLLP",
        "method": "TCP",
        "api": "raw",
        "path_template": "{host}:{port}",
        "params": {
            "host": {"description": "Target hostname", "required": True},
            "port": {"description": "TCP port", "required": True},
            "body": {"description": "HL7 message string", "required": True},
            "timeout": {"description": "Socket timeout in seconds", "default": 30},
        },
    },

    # ------------------------------------------------------------------
    # Package Reset (delete docs, lookups, messages)
    # ------------------------------------------------------------------
    "list-package-docs": {
        "description": "List all documents in a package (by name prefix)",
        "method": "GET",
        "api": "atelier",
        "path_template": "/v1/{namespace}/docnames/{type}?generated=0",
        "params": {
            "package": {"description": "Package name prefix (e.g. Demo.VaccineToASIIS)", "required": True},
        },
    },

    # ------------------------------------------------------------------
    # Class Introspection (via SQL on %Dictionary tables)
    # ------------------------------------------------------------------
    "class-meta": {
        "description": "Get class metadata (type, abstract, super, etc.) from %Dictionary.CompiledClass",
        "method": "POST",
        "api": "atelier",
        "path_template": "/v1/{namespace}/action/query",
        "params": {
            "class_name": {"description": "Fully qualified class name", "required": True},
        },
    },
    "class-methods": {
        "description": "Get methods from %Dictionary.CompiledMethod",
        "method": "POST",
        "api": "atelier",
        "path_template": "/v1/{namespace}/action/query",
        "params": {
            "class_name": {"description": "Fully qualified class name", "required": True},
        },
    },
    "class-properties": {
        "description": "Get properties from %Dictionary.CompiledProperty",
        "method": "POST",
        "api": "atelier",
        "path_template": "/v1/{namespace}/action/query",
        "params": {
            "class_name": {"description": "Fully qualified class name", "required": True},
        },
    },
    "class-parameters": {
        "description": "Get parameters from %Dictionary.CompiledParameter",
        "method": "POST",
        "api": "atelier",
        "path_template": "/v1/{namespace}/action/query",
        "params": {
            "class_name": {"description": "Fully qualified class name", "required": True},
        },
    },
    "class-xdata": {
        "description": "Get XData blocks from %Dictionary.CompiledXData",
        "method": "POST",
        "api": "atelier",
        "path_template": "/v1/{namespace}/action/query",
        "params": {
            "class_name": {"description": "Fully qualified class name", "required": True},
        },
    },
    "class-subclasses": {
        "description": "Get direct subclasses from %Dictionary.ClassDefinition_SubclassOf",
        "method": "POST",
        "api": "atelier",
        "path_template": "/v1/{namespace}/action/query",
        "params": {
            "class_name": {"description": "Fully qualified class name", "required": True},
        },
    },

    # ------------------------------------------------------------------
    # Session Management
    # ------------------------------------------------------------------
    "logout": {
        "description": "End the server session (CacheLogout)",
        "method": "HEAD",
        "api": "atelier",
        "path_template": "/?CacheLogout=end",
        "params": {},
    },
}


# ============================================================================
# Part B: IrisHTTP class
# ============================================================================

# MLLP framing constants
VT = b"\x0b"
FS = b"\x1c"
CR = b"\x0d"

# Production state codes
PROD_STATES = {
    1: "Running",
    2: "Stopped",
    3: "Suspended",
    4: "Troubled",
    5: "NetworkStopped",
}


def _ok(data, formatted=None):
    """Build a success result dict."""
    result = {"success": True, "data": data, "errors": []}
    if formatted is not None:
        result["formatted"] = formatted
    return result


def _err(message, data=None, errors=None):
    """Build an error result dict."""
    return {
        "success": False,
        "data": data,
        "errors": errors or [message],
    }


def _parse_query_content(body):
    """Parse the Atelier query response into (columns, rows)."""
    try:
        content = parse_atelier_response(body)
    except AtelierError as e:
        return [], [], str(e)

    columns = []
    rows = []
    if isinstance(content, list) and len(content) > 0:
        first = content[0]
        if isinstance(first, dict) and "content" in first:
            columns = first["content"]
            rows = [
                item.get("content", item) if isinstance(item, dict) else item
                for item in content[1:]
            ]
        else:
            columns = body.get("result", {}).get("columns", [])
            rows = content
    elif isinstance(content, dict):
        columns = content.get("columns", [])
        rows = content.get("rows", content.get("content", []))

    return columns, rows, None


def _build_time_filter(since_value):
    """Build a SQL time expression from a --since value."""
    since = since_value.strip()
    if ":" in since and len(since) <= 5:
        return f"CURRENT_DATE || ' {since}:00'"
    return f"'{since} 00:00:00'"


def _format_table(columns, rows):
    """Format columns and rows as an aligned text table."""
    if not columns:
        return ""
    widths = [len(str(c)) for c in columns]
    for row in rows:
        for i, val in enumerate(row):
            if i < len(widths):
                widths[i] = max(widths[i], len(str(val)))
    header = " | ".join(str(c).ljust(widths[i]) for i, c in enumerate(columns))
    separator = "-+-".join("-" * w for w in widths)
    lines = [header, separator]
    for row in rows:
        line = " | ".join(
            str(val).ljust(widths[i]) if i < len(widths) else str(val)
            for i, val in enumerate(row)
        )
        lines.append(line)
    return "\n".join(lines)


class IrisHTTP:
    """Unified HTTP client for InterSystems IRIS Atelier and InteropEditors APIs.

    Every method returns a dict: {"success": bool, "data": ..., "errors": [...]}
    Optionally includes a "formatted" key with human-readable output.
    """

    def __init__(self, server=None, namespace=None, password=None, config_path=None):
        """Initialize the client.

        Args:
            server: Server name from config/servers.json, or None for localhost.
            namespace: IRIS namespace (required for most operations).
            password: Override password (default: from config).
            config_path: Custom path to servers.json.
        """
        self.namespace = namespace

        if server is None:
            from iris_api import get_local_config
            self.server_config, self.server_name = get_local_config()
        else:
            self.server_name = server
            servers = load_servers(config_path)
            if server not in servers:
                raise ValueError(
                    f"Server '{server}' not found in config/servers.json. "
                    f"Available: {', '.join(servers.keys())}"
                )
            self.server_config = servers[server]

        self.base_url = build_base_url(self.server_config)
        self.username = self.server_config.get("username", "superuser")
        self.password = resolve_password(self.server_name, self.server_config, password)

        ws = self.server_config["webServer"]
        self.scheme = ws.get("scheme", "http")
        self.host = ws["host"]
        self.port = ws.get("port", 80)
        self.path_prefix = ws.get("pathPrefix", "")

        set_audit_context(server, namespace or "")

    def _interop_url(self, version="v3"):
        """Build InteropEditors API base URL."""
        return (
            f"{self.scheme}://{self.host}:{self.port}"
            f"{self.path_prefix}/api/interop-editors/{version}/{self.namespace}"
        )

    def _req(self, url, method="GET", data=None, timeout=30):
        """Make an authenticated Atelier API request."""
        return make_request(url, self.username, self.password,
                            method=method, data=data, timeout=timeout)

    def _interop_req(self, path, method="GET", query_params=None,
                     timeout=30, version="v3"):
        """Make an authenticated InteropEditors API request."""
        url = f"{self._interop_url(version)}{path}"
        return make_interop_request(
            url, self.username, self.password,
            method=method, query_params=query_params, timeout=timeout
        )

    def _check_namespace(self):
        """Raise if namespace is not set."""
        if not self.namespace:
            raise ValueError("Namespace is required for this operation")

    # ------------------------------------------------------------------
    # Connection & Server Info
    # ------------------------------------------------------------------

    def server_info(self):
        """Get server version and platform info."""
        status, body = self._req(f"{self.base_url}/")
        if status is None:
            return _err(f"Could not reach server: {body}")
        if status == 401:
            return _err("Authentication failed (401)")
        if status != 200:
            return _err(f"Unexpected status {status}")

        result = body.get("result", {}).get("content", body.get("result", {}))
        return _ok(result, formatted=(
            f"IRIS {result.get('version', 'unknown')} on {result.get('platform', 'unknown')}"
        ))

    def list_namespaces(self):
        """List all namespaces on the server."""
        status, body = self._req(f"{self.base_url}/v1/")
        if status != 200:
            return _err(f"Failed to list namespaces (status {status})")

        ns_result = body.get("result", {}).get("content", [])
        namespaces = []
        if isinstance(ns_result, list):
            for ns in ns_result:
                if isinstance(ns, dict):
                    namespaces.append(ns.get("name", str(ns)))
                else:
                    namespaces.append(str(ns))
        return _ok(namespaces, formatted=", ".join(namespaces))

    def test_connection(self):
        """Full connection test: server info + namespace check."""
        info = self.server_info()
        if not info["success"]:
            return info

        result = {"server": info["data"]}
        ns_list = self.list_namespaces()
        result["namespaces"] = ns_list.get("data", [])

        if self.namespace:
            status, _ = self._req(
                f"{self.base_url}/v1/{self.namespace}", timeout=10
            )
            result["namespace_accessible"] = status == 200

        return _ok(result)

    # ------------------------------------------------------------------
    # Document Management
    # ------------------------------------------------------------------

    def list_docs(self, doc_type="cls", filter_pattern=None):
        """List documents in the namespace.

        Args:
            doc_type: Document type (cls, mac, inc, csp).
            filter_pattern: Glob or substring filter.

        Returns:
            Result dict with data as a sorted list of document names.
        """
        self._check_namespace()
        url = f"{self.base_url}/v1/{self.namespace}/docnames/{doc_type}?generated=0"
        status, body = self._req(url)

        if status is None:
            return _err(f"Could not reach server: {body}")
        if status == 401:
            return _err("Authentication failed (401)")
        if status != 200:
            return _err(f"Unexpected status {status}")

        try:
            content = parse_atelier_response(body)
        except AtelierError as e:
            return _err(str(e))

        docs = []
        if isinstance(content, list):
            for item in content:
                if isinstance(item, dict):
                    docs.append(item.get("name", str(item)))
                else:
                    docs.append(str(item))

        if filter_pattern:
            if "*" not in filter_pattern and "?" not in filter_pattern:
                docs = [d for d in docs if filter_pattern.lower() in d.lower()]
            else:
                docs = [d for d in docs
                        if fnmatch.fnmatch(d.lower(), filter_pattern.lower())]

        docs.sort()
        return _ok(docs, formatted="\n".join(docs) + f"\n\n{len(docs)} document(s)")

    def get_doc(self, name):
        """Get a document's source code.

        Args:
            name: Document name (e.g. My.Class.cls).

        Returns:
            Result dict with data as the document text (string).
        """
        self._check_namespace()
        url = f"{self.base_url}/v1/{self.namespace}/doc/{name}"
        status, body = self._req(url)

        if status is None:
            return _err(f"Could not reach server: {body}")
        if status == 404:
            return _err(f"Document '{name}' not found in {self.namespace}")
        if status == 401:
            return _err("Authentication failed (401)")
        if status != 200:
            return _err(f"Unexpected status {status}")

        try:
            content = parse_atelier_response(body)
        except AtelierError as e:
            return _err(str(e))

        if isinstance(content, list):
            text = "\n".join(str(line) for line in content)
        else:
            text = str(content)

        # Also return the raw result for timestamp etc.
        raw_result = body.get("result", {})
        return _ok({"text": text, "ts": raw_result.get("ts"), "raw": raw_result})

    def put_doc(self, name, content, compile=True, force=False,
                flags="cuk"):
        """Save a document to the server, optionally compile.

        Args:
            name: Document name (e.g. My.Class.cls).
            content: Document content as string or list of lines.
            compile: Whether to compile after saving.
            force: Skip timestamp concurrency check.
            flags: Compile flags.

        Returns:
            Result dict with compile output, /goto directive, etc.
        """
        self._check_namespace()

        if isinstance(content, str):
            lines = content.split("\n")
        else:
            lines = list(content)

        text = "\n".join(str(line) for line in lines)

        # Fetch current state for concurrency control
        get_url = f"{self.base_url}/v1/{self.namespace}/doc/{name}"
        get_status, get_body = self._req(get_url)

        ts = None
        before_content = None
        if get_status == 200 and isinstance(get_body, dict):
            result = get_body.get("result", {})
            ts = result.get("ts")
            old_content = result.get("content", [])
            if isinstance(old_content, list):
                before_content = "\n".join(str(line) for line in old_content)
            elif old_content:
                before_content = str(old_content)

        put_data = {"enc": False, "content": lines}
        if not force and ts is not None:
            put_data["ts"] = ts

        url = f"{self.base_url}/v1/{self.namespace}/doc/{name}"
        status, body = self._req(url, method="PUT", data=put_data)

        # Handle 409 conflict with force
        if status == 409 and force:
            self._req(url, method="DELETE")
            put_data.pop("ts", None)
            status, body = self._req(url, method="PUT", data=put_data)

        if status is None:
            return _err(f"Could not reach server: {body}")
        if status == 401:
            return _err("Authentication failed (401)")
        if status not in (200, 201):
            errors = []
            if isinstance(body, dict):
                try:
                    parse_atelier_response(body)
                except AtelierError as e:
                    errors.append(str(e))
            return _err(f"Save failed with status {status}", errors=errors)

        is_create = status == 201
        output = {
            "action": "create" if is_create else "update",
            "name": name,
            "namespace": self.namespace,
        }

        # Compile
        if compile:
            compile_result = self.compile([name], flags=flags)
            output["compile"] = compile_result

            if compile_result["success"]:
                # Generate OPEN: directive with legacy-ui URL
                goto = self._build_goto(name)
                if goto:
                    output["goto"] = goto

        return _ok(output)

    def _build_goto(self, doc_name, source_text=None):
        """Build /goto directive from a document name.

        Returns a string like:
          /goto --dtl ClassName       (Angular interop-editor auto-navigate)
        """
        class_name = doc_name
        if class_name.endswith(".cls"):
            class_name = class_name[:-4]

        # Determine component type from source (deterministic) then name (fallback)
        comp_type = None
        if source_text:
            comp_type = classify_from_source(source_text)
        if not comp_type:
            parts = class_name.split(".")
            parent = parts[-2].lower() if len(parts) >= 2 else ""
            lower = class_name.lower()
            if parent == "dtl":
                comp_type = "dtl"
            elif parent == "rule" or lower.endswith("routingrule"):
                comp_type = "rule"
            elif parent == "bpl":
                comp_type = "bpl"
            elif lower.endswith(".production"):
                comp_type = "production"

        lines = []
        # /goto for Angular interop-editor
        goto_flags = {"dtl": "--dtl", "rule": "--rule", "bpl": "--bpl", "lookup": "--lookup"}
        flag = goto_flags.get(comp_type, "")
        lines.append(f"/goto {flag + ' ' if flag else ''}{class_name}")

        return "\n".join(lines)

    def delete_doc(self, name):
        """Delete a document from the server."""
        self._check_namespace()
        url = f"{self.base_url}/v1/{self.namespace}/doc/{name}"
        status, body = self._req(url, method="DELETE")
        if status in (200, 204):
            return _ok({"deleted": name})
        return _err(f"Delete failed with status {status}")

    def compile(self, docs, flags="cuk"):
        """Compile one or more documents synchronously.

        Args:
            docs: List of document names.
            flags: Compile flags (default: cuk).

        Returns:
            Result dict with compile output per document.
        """
        self._check_namespace()
        url = f"{self.base_url}/v1/{self.namespace}/action/compile"
        status, body = self._req(url, method="POST", data=docs, timeout=120)

        if status is None:
            return _err(f"Could not reach server: {body}")
        if status == 401:
            return _err("Authentication failed (401)")
        if status != 200:
            errors = []
            if isinstance(body, dict):
                try:
                    parse_atelier_response(body)
                except AtelierError as e:
                    errors.append(str(e))
            return _err(f"Compilation failed with status {status}", errors=errors)

        try:
            result = parse_atelier_response(body)
        except AtelierError as e:
            return _err(f"Compile error: {e}")

        compile_output = []
        has_errors = False
        if isinstance(result, list):
            for item in result:
                if isinstance(item, dict):
                    doc_name = item.get("name", "unknown")
                    content = item.get("content", [])
                    doc_result = {"name": doc_name, "messages": []}
                    for line in content:
                        if isinstance(line, dict):
                            doc_result["messages"].append(line)
                            if line.get("severity", "").lower() == "error":
                                has_errors = True
                        else:
                            doc_result["messages"].append({"text": str(line)})
                    compile_output.append(doc_result)

        data = {"results": compile_output, "has_errors": has_errors}
        if has_errors:
            return _err("Compilation completed with errors", data=data)
        return _ok(data)

    # ------------------------------------------------------------------
    # SQL Queries
    # ------------------------------------------------------------------

    def query(self, sql):
        """Execute a SQL query.

        Args:
            sql: SQL query string.

        Returns:
            Result dict with columns and rows.
        """
        self._check_namespace()

        # Auto-convert INSERT INTO Ens_Util.LookupTable to INSERT OR UPDATE
        sql_clean = sql.strip()
        sql_upper = sql_clean.upper()
        if (sql_upper.startswith("INSERT INTO") and "OR UPDATE" not in sql_upper
                and "ENS_UTIL.LOOKUPTABLE" in sql_upper):
            sql_clean = sql_clean[:6] + " OR UPDATE" + sql_clean[6:]

        url = f"{self.base_url}/v1/{self.namespace}/action/query"
        status, body = self._req(url, method="POST", data={"query": sql_clean})

        if status is None:
            return _err(f"Could not reach server: {body}")
        if status == 401:
            return _err("Authentication failed (401)")
        if status != 200:
            errors = []
            if isinstance(body, dict):
                try:
                    parse_atelier_response(body)
                except AtelierError as e:
                    errors.append(str(e))
            return _err(f"Query failed with status {status}", errors=errors)

        columns, rows, err = _parse_query_content(body)
        if err:
            return _err(err)

        data = {"columns": columns, "rows": rows}
        formatted = _format_table(columns, rows) if columns else "Query executed (no results)"
        return _ok(data, formatted=formatted)

    # ------------------------------------------------------------------
    # Code Search
    # ------------------------------------------------------------------

    def search(self, query, files="*.cls,*.mac,*.int,*.inc", regex=False,
               case_sensitive=False, include_system=False,
               include_generated=False, max_results=100):
        """Search code on the server.

        Args:
            query: Search string or regex pattern.
            files: File pattern filter.
            regex: Treat query as regex.
            case_sensitive: Case-sensitive search.
            include_system: Include system files.
            include_generated: Include generated files.
            max_results: Maximum results.

        Returns:
            Result dict with list of {doc, matches} dicts.
        """
        self._check_namespace()

        params = {
            "query": query,
            "files": files,
            "sys": "1" if include_system else "0",
            "gen": "1" if include_generated else "0",
            "max": str(max_results),
            "regex": "1" if regex else "0",
            "case": "1" if case_sensitive else "0",
        }
        qs = urllib.parse.urlencode(params)
        url = f"{self.base_url}/v2/{self.namespace}/action/search?{qs}"
        status, body = self._req(url, timeout=30)

        if status != 200:
            return _err(f"Search failed (HTTP {status})")

        if not isinstance(body, dict):
            return _ok([])

        result = body.get("result", [])
        if isinstance(result, dict):
            result = result.get("content", [])

        results = []
        for item in result:
            doc = item.get("doc", "")
            matches = []
            for m in item.get("matches", []):
                matches.append({
                    "text": m.get("text", ""),
                    "line": m.get("line", 0),
                    "member": m.get("member", ""),
                    "attr": m.get("attr", ""),
                })
            if matches:
                results.append({"doc": doc, "matches": matches})

        total = sum(len(r["matches"]) for r in results)
        formatted = f"Found {total} match(es) in {len(results)} file(s)"
        return _ok(results, formatted=formatted)

    # ------------------------------------------------------------------
    # HL7 Schema Introspection (raw HTTP calls -- parsing stays external)
    # ------------------------------------------------------------------

    def get_schema_raw(self, category):
        """Fetch an HL7 schema XML document.

        Args:
            category: Schema category (e.g. '2.5.1').

        Returns:
            Result dict with raw XML text in data.
        """
        self._check_namespace()
        url = f"{self.base_url}/v1/{self.namespace}/doc/{category}.HL7"
        status, body = self._req(url, timeout=30)

        if status is None:
            return _err(f"Could not reach server: {body}")
        if status == 404:
            return _err(f"Schema '{category}.HL7' not found in {self.namespace}")
        if status != 200:
            return _err(f"Unexpected status {status}")

        try:
            content = parse_atelier_response(body)
        except AtelierError as e:
            return _err(str(e))

        xml_text = "\n".join(str(line) for line in content)
        return _ok({"xml": xml_text, "category": category})

    def list_schema_categories(self):
        """List available HL7 schema categories."""
        self._check_namespace()
        sql = "SELECT Category, Description, IsStandard FROM EnsLib_HL7.Schema_TypeCategories()"
        return self.query(sql)

    # ------------------------------------------------------------------
    # Production Management
    # ------------------------------------------------------------------

    def production_status(self):
        """Get the running production name and status."""
        self._check_namespace()
        status, body = self._interop_req("/productions/status")
        if status != 200:
            return _err(f"Failed to get production status (HTTP {status})")

        state_code = body.get("State", 2)
        prod_name = body.get("ProdRunning", "")
        state_text = PROD_STATES.get(state_code, f"Unknown({state_code})")

        data = {"name": prod_name, "state": state_text, "state_code": state_code}
        if prod_name:
            formatted = f"Production: {prod_name}\nStatus: {state_text}"
        else:
            formatted = "No production is running"
        return _ok(data, formatted=formatted)

    def production_list(self):
        """List all productions in the namespace."""
        self._check_namespace()
        status, body = self._interop_req("/productions")
        if status != 200:
            return _err(f"Failed to list productions (HTTP {status})")

        prods = body.get("productions", [])
        return _ok(prods)

    def production_start(self, name, stop_first=False):
        """Start a production.

        Args:
            name: Production class name.
            stop_first: Stop any running production first.

        Returns:
            Result dict.
        """
        self._check_namespace()

        if stop_first:
            stop_result = self._production_stop_any()
            if not stop_result["success"]:
                return stop_result

        status, body = self._interop_req(
            f"/productions/state/{name}",
            method="POST",
            query_params={"state": "start", "hostID": "0"},
            timeout=120,
        )

        if status == 200 and body.get("Success"):
            return _ok({"name": name, "state": "Running"})
        error = body.get("summary", body.get("errors", str(body)))
        return _err(f"Failed to start production: {error}")

    def production_stop(self, name=None, force=False):
        """Stop the running production.

        Args:
            name: Production name (auto-detected if None).
            force: Use force stop.

        Returns:
            Result dict.
        """
        self._check_namespace()
        if not name:
            ps = self.production_status()
            if ps["success"]:
                name = ps["data"].get("name")
            if not name:
                return _err("No production is running")

        state = "force" if force else "stop"
        status, body = self._interop_req(
            f"/productions/state/{name}",
            method="POST",
            query_params={"state": state, "hostID": "0"},
            timeout=120,
        )

        if status == 200 and body.get("Success"):
            return _ok({"name": name, "state": "Stopped"})
        error = body.get("summary", body.get("errors", str(body)))
        return _err(f"Failed to stop production: {error}")

    def _production_stop_any(self):
        """Stop any running production (for stop_first logic)."""
        ps = self.production_status()
        if not ps["success"]:
            return _ok(None)  # No production info, proceed anyway

        name = ps["data"].get("name")
        state = ps["data"].get("state")

        if not name or state == "Stopped":
            return _ok(None)  # Nothing to stop

        if state == "Suspended":
            self.production_recover(name)

        result = self.production_stop(name)
        if not result["success"]:
            # Try force stop
            result = self.production_stop(name, force=True)
        return result

    def production_recover(self, name=None):
        """Recover a suspended production."""
        self._check_namespace()
        if not name:
            ps = self.production_status()
            if ps["success"]:
                name = ps["data"].get("name")
            if not name:
                return _err("No production to recover")

        status, body = self._interop_req(
            f"/productions/state/{name}",
            method="POST",
            query_params={"state": "recover", "hostID": "0"},
            timeout=120,
        )

        if status == 200 and body.get("Success"):
            return _ok({"name": name, "state": "Recovered"})
        error = body.get("summary", body.get("errors", str(body)))
        return _err(f"Failed to recover production: {error}")

    def production_clean(self):
        """Clean a production via SQL-based ObjectScript execution.

        Uses a temporary SQL function to call Ens.Director.CleanProduction().
        """
        self._check_namespace()
        # Create temporary SQL function
        create_fn = (
            "CREATE OR REPLACE FUNCTION Tmp.ExecOS(code VARCHAR(32000)) "
            "RETURNS VARCHAR(32000) LANGUAGE OBJECTSCRIPT "
            "{ new result  xecute code  quit $get(result) }"
        )
        self.query(create_fn)

        # Execute CleanProduction
        result = self.query(
            "SELECT Tmp.ExecOS('set result=##class(Ens.Director).CleanProduction(0)')"
        )
        if result["success"] and result["data"]["rows"]:
            val = result["data"]["rows"][0]
            if isinstance(val, list):
                val = val[0] if val else ""
            if val in ("1", ""):
                return _ok({"cleaned": True})
            return _err(f"CleanProduction returned: {val}")
        return _err("Failed to execute CleanProduction")

    # ------------------------------------------------------------------
    # Host Settings Introspection
    # ------------------------------------------------------------------

    def get_settings(self, cls, host_type, production=None, filter_pattern=None):
        """Get available settings for a business host class.

        Args:
            cls: Host class name (e.g. EnsLib.HL7.Service.HTTPService).
            host_type: Type: service, process, operation.
            production: Production name (auto-detected if None).
            filter_pattern: Filter settings by name.

        Returns:
            Result dict with settings list.
        """
        self._check_namespace()

        if not production:
            status, body = self._interop_req("/productions")
            if status == 200:
                prods = body.get("productions", [])
                if prods:
                    production = prods[0]
            if not production:
                return _err("No production found. Specify --production.")

        url = f"/productions/{production}/{host_type}/{cls}/settings"
        status, body = self._interop_req(url)

        if status != 200:
            return _err(f"Failed to get settings (HTTP {status})")

        settings = body if isinstance(body, list) else []

        if filter_pattern:
            pattern = filter_pattern.lower()
            settings = [s for s in settings if pattern in s.get("name", "").lower()]

        return _ok(settings)

    # ------------------------------------------------------------------
    # DTL Testing
    # ------------------------------------------------------------------

    def test_dtl(self, dtl_class, source_body):
        """Test a DTL transformation.

        Args:
            dtl_class: DTL class name.
            source_body: HL7 message string to transform.

        Returns:
            Result dict with transformed message in data.
        """
        self._check_namespace()
        status, body = self._interop_req(
            f"/dtl/test/{dtl_class}",
            method="POST",
            query_params={"inputMessage": source_body},
            timeout=30,
        )

        if status != 200:
            error = body.get("summary", str(body)) if isinstance(body, dict) else str(body)
            return _err(f"DTL test failed (status {status}): {error}")

        raw = body.get("raw", "")
        if not raw:
            return _err("DTL test returned empty result")

        return _ok({"raw": raw, "dtl_class": dtl_class})

    # ------------------------------------------------------------------
    # Lookup Tables
    # ------------------------------------------------------------------

    def get_lookup_tables(self):
        """List all lookup tables (via InteropEditors v1)."""
        self._check_namespace()
        status, body = self._interop_req("/lookup-tables", version="v1")
        if status != 200:
            return _err(f"Failed to get lookup tables (HTTP {status})")
        return _ok(body)

    # ------------------------------------------------------------------
    # Error Checking
    # ------------------------------------------------------------------

    def get_errors(self, package=None, count=20, since=None):
        """Query errors from event log and errored/suspended messages.

        Args:
            package: Filter by package name prefix.
            count: Number of recent errors to show.
            since: Only show errors since (HH:MM or YYYY-MM-DD).

        Returns:
            Result dict with event_log and messages sections.
        """
        self._check_namespace()

        # Event log query
        log_conditions = ["Type IN ('Error', 'Warning')"]
        if package:
            log_conditions.append(f"ConfigName LIKE '{package}.%'")
        if since:
            time_expr = _build_time_filter(since)
            log_conditions.append(f"TimeLogged >= {time_expr}")

        where_clause = " AND ".join(log_conditions)
        log_sql = (
            f"SELECT TOP {count} ID, TimeLogged, Type, ConfigName, "
            f"SourceClass, SourceMethod, Text "
            f"FROM Ens_Util.Log "
            f"WHERE {where_clause} "
            f"ORDER BY ID DESC"
        )
        log_result = self.query(log_sql)

        # Errored/suspended messages query
        msg_conditions = ["Status IN (5, 6)"]
        if package:
            msg_conditions.append(
                f"(SourceConfigName LIKE '{package}.%' "
                f"OR TargetConfigName LIKE '{package}.%')"
            )
        if since:
            time_expr = _build_time_filter(since)
            msg_conditions.append(f"TimeCreated >= {time_expr}")

        msg_where = " AND ".join(msg_conditions)
        msg_sql = (
            f"SELECT TOP {count} ID, TimeCreated, SessionId, "
            f"SourceConfigName, TargetConfigName, "
            f"CASE Status WHEN 5 THEN 'Error' WHEN 6 THEN 'Suspended' ELSE Status END AS Status "
            f"FROM Ens.MessageHeader "
            f"WHERE {msg_where} "
            f"ORDER BY ID DESC"
        )
        msg_result = self.query(msg_sql)

        data = {
            "event_log": {
                "columns": log_result.get("data", {}).get("columns", []),
                "rows": log_result.get("data", {}).get("rows", []),
            },
            "messages": {
                "columns": msg_result.get("data", {}).get("columns", []),
                "rows": msg_result.get("data", {}).get("rows", []),
            },
        }

        has_errors = bool(data["event_log"]["rows"] or data["messages"]["rows"])
        formatted_parts = []
        if data["event_log"]["rows"]:
            formatted_parts.append(
                "=== Event Log Errors/Warnings ===\n"
                + _format_table(data["event_log"]["columns"], data["event_log"]["rows"])
                + f"\n{len(data['event_log']['rows'])} event(s)"
            )
        else:
            formatted_parts.append("=== Event Log: No errors/warnings ===")

        if data["messages"]["rows"]:
            formatted_parts.append(
                "=== Errored/Suspended Messages ===\n"
                + _format_table(data["messages"]["columns"], data["messages"]["rows"])
                + f"\n{len(data['messages']['rows'])} message(s)"
            )
        else:
            formatted_parts.append("=== Messages: No errored/suspended messages ===")

        result = _ok(data, formatted="\n\n".join(formatted_parts))
        result["has_errors"] = has_errors
        return result

    # ------------------------------------------------------------------
    # Message Sending (HTTP)
    # ------------------------------------------------------------------

    def send_http(self, url_path, body, content_type="application/hl7-v2"):
        """Send a message via HTTP POST to a service URL.

        Args:
            url_path: URL path (e.g. /irishealth/csp/healthshare/ns/Service.cls?CfgItem=X).
            body: Message body string.
            content_type: Content-Type header.

        Returns:
            Result dict with status code and response body.
        """
        url = f"{self.scheme}://{self.host}:{self.port}{url_path}"
        credentials = base64.b64encode(
            f"{self.username}:{self.password}".encode()
        ).decode()

        req = urllib.request.Request(
            url, data=body.encode("utf-8"), method="POST"
        )
        req.add_header("Authorization", f"Basic {credentials}")
        req.add_header("Content-Type", content_type)
        req.add_header("Accept", "application/hl7-v2, application/json, text/plain")

        start = time.monotonic()
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                elapsed = int((time.monotonic() - start) * 1000)
                resp_text = resp.read().decode("utf-8", errors="replace")
                return _ok({
                    "status": resp.status,
                    "body": resp_text,
                    "elapsed_ms": elapsed,
                    "content_type": resp.headers.get("Content-Type", ""),
                })
        except urllib.error.HTTPError as e:
            elapsed = int((time.monotonic() - start) * 1000)
            resp_body = ""
            if e.fp:
                resp_body = e.read().decode("utf-8", errors="replace")
            return _err(f"HTTP {e.code}", data={
                "status": e.code,
                "body": resp_body,
                "elapsed_ms": elapsed,
            })
        except urllib.error.URLError as e:
            return _err(str(e.reason))

    def send_json(self, url_path, payload):
        """Send a JSON payload via HTTP POST.

        Args:
            url_path: URL path for the HTTP service.
            payload: JSON string.

        Returns:
            Result dict.
        """
        return self.send_http(url_path, payload, content_type="application/json")

    # ------------------------------------------------------------------
    # Message Sending (TCP/MLLP)
    # ------------------------------------------------------------------

    def send_tcp(self, host, port, message, timeout=30):
        """Send an HL7 message via TCP/MLLP.

        Args:
            host: Target hostname.
            port: TCP port.
            message: HL7 message string.
            timeout: Socket timeout in seconds.

        Returns:
            Result dict with response text and elapsed time.
        """
        payload = VT + message.encode("utf-8") + FS + CR
        start = time.monotonic()
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            sock.connect((host, int(port)))
            sock.sendall(payload)
            buf = b""
            while True:
                chunk = sock.recv(4096)
                if not chunk:
                    break
                buf += chunk
                if FS in buf:
                    break
            sock.close()
            elapsed = int((time.monotonic() - start) * 1000)

            resp = buf
            if resp.startswith(VT):
                resp = resp[1:]
            idx = resp.find(FS)
            if idx != -1:
                resp = resp[:idx]
            resp_text = resp.decode("utf-8", errors="replace")

            return _ok({
                "response": resp_text,
                "elapsed_ms": elapsed,
                "host": host,
                "port": port,
            })
        except socket.timeout:
            elapsed = int((time.monotonic() - start) * 1000)
            return _err(f"MLLP timeout after {elapsed}ms")
        except OSError as e:
            return _err(f"TCP connection failed: {e}")

    # ------------------------------------------------------------------
    # Package Reset
    # ------------------------------------------------------------------

    def list_package_docs(self, package):
        """List all server-side documents in a package.

        Args:
            package: Package name prefix (e.g. Demo.VaccineToASIIS).

        Returns:
            Result dict with sorted list of matching doc names.
        """
        self._check_namespace()
        all_docs = []

        for doc_type in ["cls", "mac", "inc"]:
            result = self.list_docs(doc_type=doc_type)
            if not result["success"]:
                continue
            for name in result["data"]:
                bare = name
                for ext in [".cls", ".mac", ".inc"]:
                    if bare.endswith(ext):
                        bare = bare[: -len(ext)]
                        break
                if bare == package or bare.startswith(package + "."):
                    all_docs.append(name)

        return _ok(sorted(all_docs))

    def delete_lookup_table(self, table_name):
        """Delete all entries from a lookup table."""
        self._check_namespace()
        sql = f"DELETE FROM Ens_Util.LookupTable WHERE TableName = '{table_name}'"
        return self.query(sql)

    def purge_messages(self, package=None):
        """Purge message headers, optionally scoped to a package."""
        self._check_namespace()
        if package:
            sql = (
                f"DELETE FROM Ens.MessageHeader "
                f"WHERE SourceConfigName LIKE '{package}.%' "
                f"OR TargetConfigName LIKE '{package}.%'"
            )
        else:
            sql = "DELETE FROM Ens.MessageHeader"
        return self.query(sql)

    # ------------------------------------------------------------------
    # Class Introspection (SQL-based)
    # ------------------------------------------------------------------

    def class_inspect(self, class_name, include_hierarchy=False,
                      include_subclasses=False):
        """Full class inspection via %Dictionary SQL queries.

        Args:
            class_name: Fully qualified class name.
            include_hierarchy: Include full inheritance chain.
            include_subclasses: Include direct subclasses.

        Returns:
            Result dict with structured class info.
        """
        self._check_namespace()

        # Class metadata
        meta_result = self.query(
            f"SELECT ClassType, Abstract, Description, Super, PrimarySuper, Deprecated "
            f"FROM %Dictionary.CompiledClass WHERE Name = '{class_name}'"
        )
        if not meta_result["success"] or not meta_result["data"]["rows"]:
            return _err(f"Class '{class_name}' not found in namespace '{self.namespace}'")

        # Parse metadata from first row
        cols = meta_result["data"]["columns"]
        row = meta_result["data"]["rows"][0]
        meta = dict(zip(cols, row)) if isinstance(row, list) else row

        def to_bool(v):
            return str(v) in ("1", "true", "True") if v else False

        def to_str(v):
            return str(v) if v not in (None, False) else ""

        super_str = to_str(meta.get("Super", ""))
        data = {
            "class": class_name,
            "classType": to_str(meta.get("ClassType")) or "registered",
            "abstract": to_bool(meta.get("Abstract")),
            "deprecated": to_bool(meta.get("Deprecated")),
            "description": to_str(meta.get("Description", "")).strip(),
            "super": [s.strip() for s in super_str.split(",") if s.strip()],
        }

        # Methods
        methods_result = self.query(
            f"SELECT Name, Description, FormalSpec, ReturnType, "
            f"ClassMethod, Origin, Deprecated "
            f"FROM %Dictionary.CompiledMethod "
            f"WHERE Parent = '{class_name}' AND Stub IS NULL "
            f"ORDER BY Name"
        )
        data["methods"] = self._rows_to_dicts(methods_result)

        # Properties
        props_result = self.query(
            f"SELECT Name, Description, RuntimeType, Collection, "
            f"Origin, Deprecated, Calculated "
            f"FROM %Dictionary.CompiledProperty "
            f"WHERE Parent = '{class_name}' ORDER BY Name"
        )
        data["properties"] = self._rows_to_dicts(props_result)

        # Parameters
        params_result = self.query(
            f"SELECT Name, Description, Type, Origin, Deprecated, \"Default\" "
            f"FROM %Dictionary.CompiledParameter "
            f"WHERE Parent = '{class_name}' ORDER BY Name"
        )
        data["parameters"] = self._rows_to_dicts(params_result)

        # XData
        xdata_result = self.query(
            f"SELECT Name, Description, MimeType, Origin "
            f"FROM %Dictionary.CompiledXData "
            f"WHERE Parent = '{class_name}' ORDER BY Name"
        )
        data["xdata"] = self._rows_to_dicts(xdata_result)

        # Indexes
        idx_result = self.query(
            f"SELECT Name, Description, Origin, Type, Properties "
            f"FROM %Dictionary.CompiledIndex "
            f"WHERE Parent = '{class_name}' ORDER BY Name"
        )
        data["indexes"] = self._rows_to_dicts(idx_result)

        # Optional: subclasses
        if include_subclasses:
            sub_result = self.query(
                f"SELECT Name FROM %Dictionary.ClassDefinition_SubclassOf('{class_name}') "
                f"ORDER BY Name"
            )
            data["subclasses"] = [
                r.get("Name", "") if isinstance(r, dict) else (r[0] if isinstance(r, list) and r else "")
                for r in sub_result.get("data", {}).get("rows", [])
            ]

        # Optional: inheritance chain
        if include_hierarchy:
            chain = []
            visited = set()
            to_visit = [class_name]
            while to_visit:
                current = to_visit.pop(0)
                if current in visited:
                    continue
                visited.add(current)
                cr = self.query(
                    f"SELECT Super FROM %Dictionary.CompiledClass WHERE Name = '{current}'"
                )
                if cr["success"] and cr["data"]["rows"]:
                    row0 = cr["data"]["rows"][0]
                    sup = row0[0] if isinstance(row0, list) else row0.get("Super", "")
                    if sup:
                        for s in (s.strip() for s in str(sup).split(",") if s.strip()):
                            if s not in visited:
                                chain.append({"class": current, "extends": s})
                                to_visit.append(s)
            data["inheritanceChain"] = chain

        return _ok(data)

    def _rows_to_dicts(self, query_result):
        """Convert a query result with columns+rows to a list of dicts."""
        if not query_result.get("success"):
            return []
        columns = query_result.get("data", {}).get("columns", [])
        rows = query_result.get("data", {}).get("rows", [])
        result = []
        for row in rows:
            if isinstance(row, list) and columns:
                result.append(dict(zip(columns, row)))
            elif isinstance(row, dict):
                result.append(row)
        return result

    # ------------------------------------------------------------------
    # Session
    # ------------------------------------------------------------------

    def logout(self):
        """End the server session."""
        url = f"{self.base_url}/?CacheLogout=end"
        self._req(url, method="HEAD", timeout=5)
        return _ok({"logged_out": True})


# ============================================================================
# Part C: CLI interface
# ============================================================================

def _add_common_args(parser):
    """Add common --server and --ns arguments."""
    parser.add_argument("--server", "-s", required=True,
                        help="Server name from config/servers.json")
    parser.add_argument("--ns", "--namespace", "-n", dest="namespace",
                        help="IRIS namespace")
    parser.add_argument("--password", "-p", help="Password (overrides config)")
    parser.add_argument("--config", help="Path to servers.json")
    parser.add_argument("--json", dest="output_json", action="store_true",
                        help="Output as JSON")


def _get_client(args):
    """Create an IrisHTTP client from parsed CLI args."""
    return IrisHTTP(
        server=args.server,
        namespace=getattr(args, "namespace", None),
        password=getattr(args, "password", None),
        config_path=getattr(args, "config", None),
    )


def _output(result, as_json=False):
    """Print a result dict -- either JSON or formatted text."""
    if as_json:
        print(json.dumps(result, indent=2, default=str))
    elif result.get("formatted"):
        print(result["formatted"])
    elif result["success"]:
        print(json.dumps(result["data"], indent=2, default=str))
    else:
        for err in result.get("errors", []):
            print(f"ERROR: {err}", file=sys.stderr)

    return 0 if result.get("success") else 1


def main():
    parser = argparse.ArgumentParser(
        description="Unified HTTP API client for InterSystems IRIS",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    _add_common_args(parser)

    subparsers = parser.add_subparsers(dest="command", help="Command to execute")

    # --- list-endpoints ---
    sub = subparsers.add_parser("list-endpoints",
                                help="Show all available API endpoints")

    # --- server-info ---
    sub = subparsers.add_parser("server-info",
                                help="Get server version and platform info")

    # --- test-connection ---
    sub = subparsers.add_parser("test-connection",
                                help="Full connection test")

    # --- list-docs ---
    sub = subparsers.add_parser("list-docs",
                                help="List documents in the namespace")
    sub.add_argument("--type", "-t", default="cls",
                     choices=["cls", "mac", "inc", "csp"],
                     help="Document type (default: cls)")
    sub.add_argument("--filter", "-f", default=None,
                     help="Glob or substring filter")

    # --- get-doc ---
    sub = subparsers.add_parser("get-doc",
                                help="Get a document's source code")
    sub.add_argument("name", help="Document name (e.g. My.Class.cls)")
    sub.add_argument("--output", "-o", help="Save to file")

    # --- put-doc ---
    sub = subparsers.add_parser("put-doc",
                                help="Push a document to the server")
    sub.add_argument("name", help="Document name (e.g. My.Class.cls)")
    sub.add_argument("--input", "-i", required=True,
                     help="Input file path")
    sub.add_argument("--compile", action="store_true", default=True,
                     help="Compile after saving (default: True)")
    sub.add_argument("--no-compile", action="store_false", dest="compile",
                     help="Skip compilation")
    sub.add_argument("--force", action="store_true",
                     help="Skip timestamp concurrency check")
    sub.add_argument("--flags", default="cuk",
                     help="Compile flags (default: cuk)")

    # --- delete-doc ---
    sub = subparsers.add_parser("delete-doc",
                                help="Delete a document from the server")
    sub.add_argument("name", help="Document name")

    # --- compile ---
    sub = subparsers.add_parser("compile",
                                help="Compile documents on the server")
    sub.add_argument("docs", help="Comma-separated document names")
    sub.add_argument("--flags", default="cuk",
                     help="Compile flags (default: cuk)")

    # --- query ---
    sub = subparsers.add_parser("query",
                                help="Execute a SQL query")
    sub.add_argument("sql", help="SQL query string")
    sub.add_argument("--format", choices=["table", "json", "csv"],
                     default="table", help="Output format")

    # --- search ---
    sub = subparsers.add_parser("search",
                                help="Search code on the server")
    sub.add_argument("query_text", metavar="QUERY",
                     help="Search string or regex")
    sub.add_argument("--files", default="*.cls,*.mac,*.int,*.inc",
                     help="File pattern filter")
    sub.add_argument("--regex", action="store_true",
                     help="Treat query as regex")
    sub.add_argument("--max", type=int, default=100,
                     help="Max results")

    # --- send ---
    sub = subparsers.add_parser("send",
                                help="Send a message via HTTP or TCP")
    sub.add_argument("--url", "-u",
                     help="HTTP URL path (for HTTP sends)")
    sub.add_argument("--input", "-i",
                     help="Input file")
    sub.add_argument("--content-type", default="application/hl7-v2",
                     help="Content-Type (default: application/hl7-v2)")
    sub.add_argument("--tcp", action="store_true",
                     help="Use TCP/MLLP transport")
    sub.add_argument("--host", help="TCP host")
    sub.add_argument("--port", type=int, help="TCP port")

    # --- production ---
    sub = subparsers.add_parser("production",
                                help="Production management")
    sub.add_argument("action",
                     choices=["status", "list", "start", "stop", "recover", "clean"],
                     help="Production action")
    sub.add_argument("--name", help="Production class name (for start)")
    sub.add_argument("--stop-first", action="store_true",
                     help="Stop running production before starting")
    sub.add_argument("--force", action="store_true",
                     help="Force stop")

    # --- errors ---
    sub = subparsers.add_parser("errors",
                                help="Check for errors in event log and messages")
    sub.add_argument("--package", help="Filter by package name")
    sub.add_argument("--count", type=int, default=20,
                     help="Number of recent errors (default: 20)")
    sub.add_argument("--since", help="Only show since (HH:MM or YYYY-MM-DD)")

    # --- settings ---
    sub = subparsers.add_parser("settings",
                                help="Get business host settings")
    sub.add_argument("--class", dest="cls", required=True,
                     help="Host class name")
    sub.add_argument("--type", "-t", required=True,
                     choices=["service", "process", "operation"],
                     help="Host type")
    sub.add_argument("--production", help="Production name (auto-detected)")
    sub.add_argument("--filter", help="Filter settings by name")

    # --- test-dtl ---
    sub = subparsers.add_parser("test-dtl",
                                help="Test a DTL transformation")
    sub.add_argument("--dtl", required=True, help="DTL class name")
    sub.add_argument("--input", "-i", help="Input HL7 message file")

    # --- inspect ---
    sub = subparsers.add_parser("inspect",
                                help="Inspect a class structure")
    sub.add_argument("class_name", help="Fully qualified class name")
    sub.add_argument("--hierarchy", action="store_true",
                     help="Include inheritance chain")
    sub.add_argument("--subclasses", action="store_true",
                     help="Include direct subclasses")

    # --- schema ---
    sub = subparsers.add_parser("schema",
                                help="HL7 schema operations")
    sub.add_argument("--list-categories", action="store_true",
                     help="List schema categories")
    sub.add_argument("--get", metavar="CATEGORY",
                     help="Get schema XML for a category (e.g. 2.5.1)")

    # --- package ---
    sub = subparsers.add_parser("package",
                                help="Package operations (list docs, reset)")
    sub.add_argument("action", choices=["list", "delete-lookup", "purge-messages"],
                     help="Package action")
    sub.add_argument("--name", required=True,
                     help="Package name prefix")
    sub.add_argument("--lookup", help="Lookup table name (for delete-lookup)")

    # --- lookup ---
    sub = subparsers.add_parser("lookup",
                                help="List lookup tables")

    # Parse
    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    use_json = getattr(args, "output_json", False)

    # --- list-endpoints (no client needed) ---
    if args.command == "list-endpoints":
        if use_json:
            print(json.dumps(ENDPOINTS, indent=2))
        else:
            print(f"{'Endpoint':<30} {'Method':<8} {'API':<20} {'Description'}")
            print("-" * 100)
            for name, ep in sorted(ENDPOINTS.items()):
                api_label = ep.get("api", "")
                if ep.get("api_version"):
                    api_label += f" {ep['api_version']}"
                print(f"{name:<30} {ep['method']:<8} {api_label:<20} {ep['description']}")
        sys.exit(0)

    # Create client
    try:
        client = _get_client(args)
    except ValueError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)

    # --- Dispatch commands ---
    result = None

    if args.command == "server-info":
        result = client.server_info()

    elif args.command == "test-connection":
        result = client.test_connection()

    elif args.command == "list-docs":
        result = client.list_docs(
            doc_type=args.type,
            filter_pattern=args.filter,
        )

    elif args.command == "get-doc":
        result = client.get_doc(args.name)
        if result["success"] and not use_json:
            # For get-doc, print the text directly unless --json
            text = result["data"]["text"]
            if getattr(args, "output", None):
                out_dir = os.path.dirname(args.output)
                if out_dir:
                    os.makedirs(out_dir, exist_ok=True)
                with open(args.output, "w", encoding="utf-8") as f:
                    f.write(text)
                print(f"Saved to {args.output}", file=sys.stderr)
            else:
                print(text)
            sys.exit(0)

    elif args.command == "put-doc":
        if not os.path.exists(args.input):
            print(f"ERROR: File not found: {args.input}", file=sys.stderr)
            sys.exit(1)
        with open(args.input, "r", encoding="utf-8") as f:
            content = f.read()
        result = client.put_doc(
            args.name, content,
            compile=args.compile,
            force=args.force,
            flags=args.flags,
        )
        if result["success"]:
            data = result["data"]
            action = data.get("action", "saved")
            print(f"OK: {action.title()} '{args.name}' in {client.namespace}")
            if data.get("compile", {}).get("success"):
                print(f"OK: Compiled '{args.name}'")
            if data.get("goto"):
                print(data["goto"])
            sys.exit(0)

    elif args.command == "delete-doc":
        result = client.delete_doc(args.name)

    elif args.command == "compile":
        doc_list = [d.strip() for d in args.docs.split(",") if d.strip()]
        result = client.compile(doc_list, flags=args.flags)

    elif args.command == "query":
        result = client.query(args.sql)
        if result["success"] and not use_json:
            fmt = getattr(args, "format", "table")
            if fmt == "json":
                cols = result["data"]["columns"]
                rows = result["data"]["rows"]
                json_rows = []
                for row in rows:
                    if isinstance(row, list) and cols:
                        json_rows.append(dict(zip(cols, row)))
                    else:
                        json_rows.append(row)
                print(json.dumps(json_rows, indent=2))
            elif fmt == "csv":
                import csv
                import io
                cols = result["data"]["columns"]
                rows = result["data"]["rows"]
                output = io.StringIO()
                writer = csv.writer(output)
                writer.writerow(cols)
                for row in rows:
                    writer.writerow(row)
                print(output.getvalue())
            else:
                print(result.get("formatted", ""))
                print(f"\n{len(result['data']['rows'])} row(s)", file=sys.stderr)
            sys.exit(0)

    elif args.command == "search":
        result = client.search(
            query=args.query_text,
            files=args.files,
            regex=args.regex,
            max_results=args.max,
        )
        if result["success"] and not use_json:
            data = result["data"]
            total = sum(len(r["matches"]) for r in data)
            print(f"Found {total} match(es) in {len(data)} file(s):\n")
            for r in data:
                print(f"  {r['doc']}")
                for m in r["matches"]:
                    member = f" [{m['member']}]" if m.get("member") else ""
                    print(f"    {m['line']:5d}{member}: {m['text'].strip()}")
                print()
            sys.exit(0)

    elif args.command == "send":
        # Read message content
        if args.input:
            if not os.path.exists(args.input):
                print(f"ERROR: File not found: {args.input}", file=sys.stderr)
                sys.exit(1)
            with open(args.input, "r", encoding="utf-8") as f:
                body = f.read()
        else:
            body = sys.stdin.read()

        if not body.strip():
            print("ERROR: No message content provided", file=sys.stderr)
            sys.exit(1)

        if args.tcp:
            if not args.host or not args.port:
                print("ERROR: --host and --port required for TCP", file=sys.stderr)
                sys.exit(1)
            result = client.send_tcp(args.host, args.port, body.strip())
        else:
            if not args.url:
                print("ERROR: --url required for HTTP send", file=sys.stderr)
                sys.exit(1)
            result = client.send_http(args.url, body.strip(), args.content_type)

    elif args.command == "production":
        if args.action == "status":
            result = client.production_status()
        elif args.action == "list":
            result = client.production_list()
        elif args.action == "start":
            if not args.name:
                print("ERROR: --name required for production start", file=sys.stderr)
                sys.exit(1)
            result = client.production_start(args.name, stop_first=args.stop_first)
        elif args.action == "stop":
            result = client.production_stop(force=args.force)
        elif args.action == "recover":
            result = client.production_recover()
        elif args.action == "clean":
            result = client.production_clean()

    elif args.command == "errors":
        result = client.get_errors(
            package=args.package,
            count=args.count,
            since=args.since,
        )

    elif args.command == "settings":
        result = client.get_settings(
            cls=args.cls,
            host_type=args.type,
            production=args.production,
            filter_pattern=args.filter,
        )

    elif args.command == "test-dtl":
        if not args.input:
            print("ERROR: --input required for test-dtl", file=sys.stderr)
            sys.exit(1)
        if not os.path.exists(args.input):
            print(f"ERROR: File not found: {args.input}", file=sys.stderr)
            sys.exit(1)
        with open(args.input, "r", encoding="utf-8") as f:
            hl7 = f.read().strip().replace("\r\n", "\r").replace("\n", "\r")
        result = client.test_dtl(args.dtl, hl7)

    elif args.command == "inspect":
        result = client.class_inspect(
            args.class_name,
            include_hierarchy=args.hierarchy,
            include_subclasses=args.subclasses,
        )

    elif args.command == "schema":
        if args.list_categories:
            result = client.list_schema_categories()
        elif args.get:
            result = client.get_schema_raw(args.get)
            if result["success"] and not use_json:
                print(result["data"]["xml"])
                sys.exit(0)
        else:
            print("ERROR: Specify --list-categories or --get CATEGORY", file=sys.stderr)
            sys.exit(1)

    elif args.command == "package":
        if args.action == "list":
            result = client.list_package_docs(args.name)
        elif args.action == "delete-lookup":
            if not args.lookup:
                print("ERROR: --lookup required", file=sys.stderr)
                sys.exit(1)
            result = client.delete_lookup_table(args.lookup)
        elif args.action == "purge-messages":
            result = client.purge_messages(args.name)

    elif args.command == "lookup":
        result = client.get_lookup_tables()

    else:
        parser.print_help()
        sys.exit(1)

    if result is not None:
        exit_code = _output(result, as_json=use_json)
        sys.exit(exit_code)


if __name__ == "__main__":
    main()
