#!/usr/bin/env python3
"""Inspect InterSystems class structure via SQL queries against %Dictionary tables.

Gives Claude (or any caller) full oversight of a class without downloading source:
methods, properties, parameters, XData, indexes, inheritance chain, deprecation status.

SQL patterns adapted from intersystems/language-server LSP providers.

Usage:
    class_inspect.py --server myserver --namespace HSLIB --class EnsLib.HL7.Service.HTTPService
    class_inspect.py --server myserver --namespace HSLIB --class EnsLib.HL7.Service.HTTPService --json
    class_inspect.py --server myserver --namespace HSLIB --class EnsLib.HL7.Service.HTTPService --hierarchy
    class_inspect.py --server myserver --namespace HSLIB --class Some.Class --subclasses
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import argparse
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from iris_api import load_servers, build_base_url, resolve_password, make_request, common_arg_parser


def _run_sql(base_url, namespace, username, password, sql, timeout=30):
    """Execute SQL and return list of dicts (one per row). Returns [] on error."""
    url = f"{base_url}/v1/{namespace}/action/query"
    status, body = make_request(url, username, password, method="POST",
                                data={"query": sql}, timeout=timeout)
    if status != 200 or not isinstance(body, dict):
        return []

    result = body.get("result", {})
    content = result.get("content", [])
    if not content:
        return []

    # Each row in content is a dict with column names as keys
    return content


def _to_bool(val):
    """Convert various truthy values to bool."""
    if isinstance(val, bool):
        return val
    return str(val) in ("1", "true", "True")


def _to_str(val):
    """Safely convert to string, empty string for None/False."""
    if val is None or val is False:
        return ""
    return str(val)


def _query_class_meta(base_url, ns, user, pw, cls):
    """Get class-level metadata."""
    sql = (
        f"SELECT ClassType, Abstract, Description, "
        f"Super, PrimarySuper, Deprecated "
        f"FROM %Dictionary.CompiledClass WHERE Name = '{cls}'"
    )
    rows = _run_sql(base_url, ns, user, pw, sql)
    if not rows:
        return None

    r = rows[0]
    # Super comes as comma-separated string from Atelier API
    super_str = _to_str(r.get("Super"))
    return {
        "classType": _to_str(r.get("ClassType")) or "registered",
        "abstract": _to_bool(r.get("Abstract")),
        "description": _to_str(r.get("Description")).strip().replace("\r\n", "\n"),
        "super": [s.strip() for s in super_str.split(",") if s.strip()],
        "primarySuper": _to_str(r.get("PrimarySuper")),
        "deprecated": _to_bool(r.get("Deprecated")),
    }


def _query_methods(base_url, ns, user, pw, cls):
    """Get all methods with signatures."""
    sql = (
        f"SELECT Name, Description, FormalSpec, ReturnType, "
        f"ClassMethod, Origin, Deprecated "
        f"FROM %Dictionary.CompiledMethod "
        f"WHERE Parent = '{cls}' AND Stub IS NULL "
        f"ORDER BY Name"
    )
    rows = _run_sql(base_url, ns, user, pw, sql)
    methods = []
    for r in rows:
        methods.append({
            "name": r.get("Name", ""),
            "description": _to_str(r.get("Description")).strip(),
            "formalSpec": _to_str(r.get("FormalSpec")),
            "returnType": _to_str(r.get("ReturnType")),
            "classMethod": _to_bool(r.get("ClassMethod")),
            "origin": _to_str(r.get("Origin")) or cls,
            "deprecated": _to_bool(r.get("Deprecated")),
        })
    return methods


def _query_properties(base_url, ns, user, pw, cls):
    """Get all properties with types."""
    sql = (
        f"SELECT Name, Description, RuntimeType, Collection, "
        f"Origin, Deprecated, Calculated "
        f"FROM %Dictionary.CompiledProperty "
        f"WHERE Parent = '{cls}' ORDER BY Name"
    )
    rows = _run_sql(base_url, ns, user, pw, sql)
    props = []
    for r in rows:
        ptype = _to_str(r.get("RuntimeType"))
        collection = _to_str(r.get("Collection"))
        if collection:
            ptype = f"{collection} Of {ptype}"
        props.append({
            "name": r.get("Name", ""),
            "description": _to_str(r.get("Description")).strip(),
            "type": ptype,
            "origin": _to_str(r.get("Origin")) or cls,
            "deprecated": _to_bool(r.get("Deprecated")),
            "calculated": _to_bool(r.get("Calculated")),
        })
    return props


def _query_parameters(base_url, ns, user, pw, cls):
    """Get all class parameters."""
    sql = (
        f"SELECT Name, Description, Type, Origin, Deprecated, Default "
        f"FROM %Dictionary.CompiledParameter "
        f"WHERE Parent = '{cls}' ORDER BY Name"
    )
    rows = _run_sql(base_url, ns, user, pw, sql)
    params = []
    for r in rows:
        params.append({
            "name": r.get("Name", ""),
            "description": _to_str(r.get("Description")).strip(),
            "type": _to_str(r.get("Type")),
            "origin": _to_str(r.get("Origin")) or cls,
            "deprecated": _to_bool(r.get("Deprecated")),
            "default": _to_str(r.get("Default")),
        })
    return params


def _query_xdata(base_url, ns, user, pw, cls):
    """Get XData blocks."""
    sql = (
        f"SELECT Name, Description, MimeType, Origin "
        f"FROM %Dictionary.CompiledXData "
        f"WHERE Parent = '{cls}' ORDER BY Name"
    )
    rows = _run_sql(base_url, ns, user, pw, sql)
    xdata = []
    for r in rows:
        xdata.append({
            "name": r.get("Name", ""),
            "description": _to_str(r.get("Description")).strip(),
            "mimeType": _to_str(r.get("MimeType")),
            "origin": _to_str(r.get("Origin")) or cls,
        })
    return xdata


def _query_indexes(base_url, ns, user, pw, cls):
    """Get indexes."""
    sql = (
        f"SELECT Name, Description, Origin, Type, Properties "
        f"FROM %Dictionary.CompiledIndex "
        f"WHERE Parent = '{cls}' ORDER BY Name"
    )
    rows = _run_sql(base_url, ns, user, pw, sql)
    indexes = []
    for r in rows:
        indexes.append({
            "name": r.get("Name", ""),
            "description": _to_str(r.get("Description")).strip(),
            "origin": _to_str(r.get("Origin")) or cls,
            "type": _to_str(r.get("Type")),
            "properties": _to_str(r.get("Properties")),
        })
    return indexes


def _query_subclasses(base_url, ns, user, pw, cls):
    """Get direct subclasses."""
    sql = (
        f"SELECT Name FROM %Dictionary.ClassDefinition_SubclassOf('{cls}') "
        f"ORDER BY Name"
    )
    rows = _run_sql(base_url, ns, user, pw, sql)
    return [r.get("Name", "") for r in rows if r.get("Name")]


def _query_superchain(base_url, ns, user, pw, cls):
    """Walk the full inheritance chain (recursive supers)."""
    chain = []
    visited = set()
    to_visit = [cls]

    while to_visit:
        current = to_visit.pop(0)
        if current in visited:
            continue
        visited.add(current)

        sql = (
            f"SELECT Super "
            f"FROM %Dictionary.CompiledClass WHERE Name = '{current}'"
        )
        rows = _run_sql(base_url, ns, user, pw, sql)
        if rows:
            super_str = _to_str(rows[0].get("Super"))
            if super_str:
                supers = [s.strip() for s in super_str.split(",") if s.strip()]
                for s in supers:
                    if s not in visited:
                        chain.append({"class": current, "extends": s})
                        to_visit.append(s)

    return chain


def inspect_class(base_url, namespace, username, password, class_name,
                  include_hierarchy=False, include_subclasses=False):
    """Full class inspection. Returns structured dict."""
    meta = _query_class_meta(base_url, namespace, username, password, class_name)
    if meta is None:
        return {"error": f"Class '{class_name}' not found in namespace '{namespace}'"}

    result = {
        "class": class_name,
        "classType": meta["classType"],
        "abstract": meta["abstract"],
        "deprecated": meta["deprecated"],
        "description": meta["description"],
        "super": meta["super"],
        "methods": _query_methods(base_url, namespace, username, password, class_name),
        "properties": _query_properties(base_url, namespace, username, password, class_name),
        "parameters": _query_parameters(base_url, namespace, username, password, class_name),
        "xdata": _query_xdata(base_url, namespace, username, password, class_name),
        "indexes": _query_indexes(base_url, namespace, username, password, class_name),
    }

    if include_subclasses:
        result["subclasses"] = _query_subclasses(
            base_url, namespace, username, password, class_name)

    if include_hierarchy:
        result["inheritanceChain"] = _query_superchain(
            base_url, namespace, username, password, class_name)

    return result


# ---------------------------------------------------------------------------
# Table formatting
# ---------------------------------------------------------------------------

def _format_table(title, items, columns):
    """Format a list of dicts as a table."""
    if not items:
        return ""

    # Compute column widths
    widths = {c: len(c) for c in columns}
    for item in items:
        for c in columns:
            val = str(item.get(c, ""))
            widths[c] = max(widths[c], min(len(val), 80))

    header = " | ".join(c.ljust(widths[c])[:widths[c]] for c in columns)
    sep = "-+-".join("-" * widths[c] for c in columns)

    lines = [f"\n### {title} ({len(items)})", header, sep]
    for item in items:
        row = " | ".join(str(item.get(c, "")).ljust(widths[c])[:widths[c]] for c in columns)
        lines.append(row)
    return "\n".join(lines)


def format_as_table(data):
    """Format inspection result as human-readable tables."""
    if "error" in data:
        return f"ERROR: {data['error']}"

    lines = [
        f"Class: {data['class']}",
        f"Type: {data['classType']}",
        f"Abstract: {data['abstract']}",
        f"Deprecated: {data['deprecated']}",
    ]
    if data["super"]:
        lines.append(f"Extends: {', '.join(data['super'])}")
    if data["description"]:
        lines.append(f"Description: {data['description'][:200]}")

    lines.append(_format_table(
        "Methods", data["methods"],
        ["name", "formalSpec", "returnType", "classMethod", "origin"]))

    lines.append(_format_table(
        "Properties", data["properties"],
        ["name", "type", "origin", "calculated"]))

    lines.append(_format_table(
        "Parameters", data["parameters"],
        ["name", "type", "default", "origin"]))

    if data.get("xdata"):
        lines.append(_format_table(
            "XData", data["xdata"],
            ["name", "mimeType", "origin"]))

    if data.get("indexes"):
        lines.append(_format_table(
            "Indexes", data["indexes"],
            ["name", "type", "properties", "origin"]))

    if data.get("subclasses"):
        lines.append(f"\n### Subclasses ({len(data['subclasses'])})")
        for s in data["subclasses"]:
            lines.append(f"  {s}")

    if data.get("inheritanceChain"):
        lines.append(f"\n### Inheritance Chain")
        for link in data["inheritanceChain"]:
            lines.append(f"  {link['class']} extends {link['extends']}")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = common_arg_parser("Inspect InterSystems class structure via %Dictionary queries")
    parser.add_argument("--class", "-C", dest="classname", required=True,
                        help="Fully qualified class name (e.g., EnsLib.HL7.Service.HTTPService)")
    parser.add_argument("--json", dest="output_json", action="store_true",
                        help="Output as JSON (default: table)")
    parser.add_argument("--hierarchy", action="store_true",
                        help="Include full inheritance chain")
    parser.add_argument("--subclasses", action="store_true",
                        help="Include direct subclasses")
    parser.add_argument("--format", choices=["json", "table"], default=None,
                        help="Output format (default: table)")
    args = parser.parse_args()

    use_json = args.output_json or args.format == "json"

    servers = load_servers(getattr(args, "config", None))
    server_name = args.server
    if server_name not in servers:
        print(f"ERROR: Server '{server_name}' not found", file=sys.stderr)
        sys.exit(1)

    server_config = servers[server_name]
    base_url = build_base_url(server_config)
    username = server_config.get("username", "superuser")
    password = resolve_password(server_name, server_config, getattr(args, "password", None))
    namespace = args.namespace or "USER"

    result = inspect_class(
        base_url, namespace, username, password, args.classname,
        include_hierarchy=args.hierarchy,
        include_subclasses=args.subclasses,
    )

    if "error" in result:
        print(f"ERROR: {result['error']}", file=sys.stderr)
        sys.exit(1)

    if use_json:
        print(json.dumps(result, indent=2))
    else:
        print(format_as_table(result))


if __name__ == "__main__":
    main()
