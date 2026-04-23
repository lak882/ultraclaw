#!/usr/bin/env python3
"""Get available settings for a business host class, showing Host vs Adapter target.

Queries the InteropEditors API for all settings, then uses the class hierarchy
to determine whether each setting belongs to the Host or Adapter.

Usage:
  get_settings.py --server myserver --namespace CLAUDE --class EnsLib.HL7.Service.HTTPService --type service
  get_settings.py --server myserver --namespace CLAUDE --class EnsLib.HL7.Operation.FileOperation --type operation
  get_settings.py --server myserver --namespace CLAUDE --class EnsLib.HL7.MsgRouter.RoutingEngine --type process
  get_settings.py --server myserver --namespace CLAUDE --class EnsLib.HL7.Service.TCPService --type service --production Demo.Production
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import json
import re
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import (common_arg_parser, get_server_and_creds, make_request,
                      build_interop_url, make_interop_request,
                      parse_atelier_response, AtelierError)


def get_class_source(base_url, namespace, username, password, class_name):
    """Pull class source lines from the server."""
    url = f"{base_url}/v1/{namespace}/doc/{class_name}.cls"
    status, body = make_request(url, username, password)
    if status != 200:
        return []
    return body.get("result", {}).get("content", [])


def get_superclass(lines):
    """Extract the Extends clause from class source lines."""
    for line in lines:
        if not isinstance(line, str):
            continue
        m = re.match(r'Class\s+\S+\s+Extends\s+\(?([^)\[\{]+)', line)
        if m:
            raw = m.group(1).strip().rstrip(")")
            # May be comma-separated list; extract only valid class names
            classes = []
            for part in raw.split(","):
                name = part.strip()
                # Valid class name: dotted identifiers only
                if re.match(r'^[A-Za-z%][\w.]*$', name):
                    classes.append(name)
            return classes
    return []


def get_adapter_class(lines):
    """Extract the ADAPTER parameter from class source lines."""
    for line in lines:
        if not isinstance(line, str):
            continue
        m = re.match(r'\s*Parameter\s+ADAPTER\s*=\s*"([^"]+)"', line)
        if m:
            return m.group(1)
    return None


def get_class_properties(base_url, namespace, username, password, class_name):
    """Get property names defined directly on a class (not inherited)."""
    lines = get_class_source(base_url, namespace, username, password, class_name)
    properties = set()
    for line in lines:
        if not isinstance(line, str):
            continue
        m = re.match(r'\s*Property\s+(\w+)', line)
        if m:
            properties.add(m.group(1))
    return properties, lines


def resolve_adapter_properties(base_url, namespace, username, password, host_class):
    """Walk the adapter class hierarchy to find all adapter-owned properties."""
    adapter_props = set()

    # Get the host class source to find the ADAPTER parameter
    host_lines = get_class_source(base_url, namespace, username, password, host_class)
    adapter_class = get_adapter_class(host_lines)

    if not adapter_class:
        # Walk superclasses to find ADAPTER
        supers = get_superclass(host_lines)
        for sup in supers:
            sup_lines = get_class_source(base_url, namespace, username, password, sup)
            adapter_class = get_adapter_class(sup_lines)
            if adapter_class:
                break

    if not adapter_class:
        return adapter_props

    # Walk the adapter class hierarchy collecting properties
    visited = set()
    to_visit = [adapter_class]
    while to_visit:
        cls = to_visit.pop(0)
        if cls in visited or cls.startswith("%") or cls == "Ens.InboundAdapter" or cls == "Ens.OutboundAdapter":
            continue
        visited.add(cls)

        props, lines = get_class_properties(base_url, namespace, username, password, cls)
        adapter_props.update(props)

        # Add superclasses
        supers = get_superclass(lines)
        to_visit.extend(supers)

    return adapter_props


def get_all_settings(interop_url, username, password, production, host_type, class_name):
    """Get all settings via the InteropEditors API."""
    url = f"{interop_url}/productions/{production}/{host_type}/{class_name}/settings"
    status, body = make_interop_request(url, username, password)
    if status != 200:
        return []
    if isinstance(body, list):
        return body
    return []


def find_production(interop_url, username, password):
    """Find any production in the namespace to use for settings query."""
    url = f"{interop_url}/productions"
    status, body = make_interop_request(url, username, password)
    if status == 200:
        prods = body.get("productions", [])
        if prods:
            return prods[0]
    return None


def main():
    parser = common_arg_parser("Get available settings for a business host class")
    parser.add_argument("--class", "-C", dest="cls", required=True,
                        help="Class name (e.g., EnsLib.HL7.Service.HTTPService)")
    parser.add_argument("--type", "-t", required=True,
                        choices=["service", "process", "operation"],
                        help="Host type")
    parser.add_argument("--production", "-P",
                        help="Production class (auto-detected if not specified)")
    parser.add_argument("--format", "-f", default="table",
                        choices=["table", "json", "production"],
                        help="Output format (default: table, production = XML snippet)")
    parser.add_argument("--filter", metavar="PATTERN",
                        help="Filter settings by name (case-insensitive substring match)")
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    server_config, base_url, username, password = get_server_and_creds(args)
    interop_url = build_interop_url(server_config, args.namespace)

    # Find a production to query settings against
    production = args.production
    if not production:
        production = find_production(interop_url, username, password)
        if not production:
            print("ERROR: No production found. Use --production to specify one.",
                  file=sys.stderr)
            sys.exit(1)

    # Get all settings from the API
    settings = get_all_settings(interop_url, username, password,
                                production, args.type, args.cls)
    if not settings:
        print(f"No settings found for {args.cls}", file=sys.stderr)
        sys.exit(1)

    # Resolve adapter properties to determine Target
    adapter_props = resolve_adapter_properties(base_url, args.namespace,
                                               username, password, args.cls)

    # Classify each setting
    for s in settings:
        name = s.get("name", "")
        if name in adapter_props:
            s["target"] = "Adapter"
        else:
            s["target"] = "Host"

    # Apply filter
    if args.filter:
        pattern = args.filter.lower()
        settings = [s for s in settings if pattern in s.get("name", "").lower()]

    # Output
    if args.format == "json":
        output = []
        for s in settings:
            output.append({
                "name": s.get("name", ""),
                "target": s.get("target", ""),
                "value": s.get("value", ""),
                "defaultValue": s.get("defaultValue", ""),
            })
        print(json.dumps(output, indent=2))

    elif args.format == "production":
        # Output as XML Setting elements
        print(f"<!-- Settings for {args.cls} -->")
        for s in settings:
            name = s.get("name", "")
            target = s.get("target", "Host")
            val = s.get("value", s.get("defaultValue", ""))
            if val == "" or val is None:
                continue
            print(f'<Setting Target="{target}" Name="{name}">{val}</Setting>')

    else:
        # Table format
        print(f"=== Settings for {args.cls} ===\n")
        print(f"{'Target':8} {'Name':35} {'Default':20}")
        print(f"{'------':8} {'----':35} {'-------':20}")
        for s in settings:
            name = s.get("name", "")
            target = s.get("target", "")
            default = str(s.get("value", s.get("defaultValue", "")))
            if len(default) > 20:
                default = default[:17] + "..."
            print(f"{target:8} {name:35} {default:20}")

        print(f"\n{len(settings)} setting(s)")


if __name__ == "__main__":
    main()
