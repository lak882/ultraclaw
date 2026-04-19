#!/usr/bin/env python3
"""Generate a Mermaid flowchart diagram of an InterSystems production's message flow.

Pulls the production class, parses its XML, resolves routing rules and BPL
processes, and outputs a Mermaid LR (left-to-right) flowchart to stdout.
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import re
import sys
import os
import xml.etree.ElementTree as ET

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import common_arg_parser, get_server_and_creds, make_request, parse_atelier_response


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def fetch_document(base_url, namespace, username, password, doc_name):
    """Fetch a document from the server, return its text or None."""
    url = f"{base_url}/v1/{namespace}/doc/{doc_name}"
    status, body = make_request(url, username, password)
    if status != 200:
        return None
    try:
        content = parse_atelier_response(body)
    except Exception:
        return None
    if isinstance(content, list):
        return "\n".join(str(line) for line in content)
    return str(content)


def extract_xdata_xml(cls_text):
    """Extract the XML content from an XData ProductionDefinition block."""
    if cls_text is None:
        return None
    # Find the XData block content between { ... }
    m = re.search(r'XData\s+ProductionDefinition\s*\{(.*?)\n\}', cls_text, re.DOTALL)
    if not m:
        return None
    return m.group(1).strip()


def extract_xdata_block(cls_text, block_name="RuleDefinition"):
    """Extract XML from a named XData block."""
    if cls_text is None:
        return None
    pattern = rf'XData\s+{block_name}\s*\{{(.*?)\n\}}'
    m = re.search(pattern, cls_text, re.DOTALL)
    if not m:
        return None
    return m.group(1).strip()


def sanitize_id(name):
    """Create a safe Mermaid node ID from a class/config name."""
    return re.sub(r'[^a-zA-Z0-9_]', '_', name)


# ---------------------------------------------------------------------------
# Production XML parsing
# ---------------------------------------------------------------------------

def parse_production_xml(xml_text):
    """Parse production XML and return categorized hosts.

    Returns dict with keys: services, processes, operations.
    Each value is a list of dicts with: name, class_name, category, targets, settings.
    """
    root = ET.fromstring(xml_text)

    hosts = {"services": [], "processes": [], "operations": []}

    for item in root.findall(".//Item"):
        name = item.get("Name", "")
        class_name = item.get("ClassName", "")
        category = item.get("Category", "")
        enabled = item.get("Enabled", "true")

        # Parse settings
        settings = {}
        for setting in item.findall("Setting"):
            sname = setting.get("Name", "")
            sval = setting.get("Value", setting.text or "")
            settings[sname] = sval

        # Determine host type from built-in class patterns
        host_info = {
            "name": name,
            "class_name": class_name,
            "category": category,
            "enabled": enabled.lower() == "true",
            "settings": settings,
            "targets": [],
        }

        # Classify by class type
        if is_service_class(class_name):
            hosts["services"].append(host_info)
        elif is_operation_class(class_name):
            hosts["operations"].append(host_info)
        else:
            # Default to process
            hosts["processes"].append(host_info)

        # Extract targets from settings
        target_names = settings.get("TargetConfigNames", "")
        if target_names:
            host_info["targets"] = [t.strip() for t in target_names.split(",") if t.strip()]

    return hosts


def is_service_class(class_name):
    """Heuristic to detect Business Service classes."""
    service_patterns = [
        "Service", "EnsLib.HL7.Service", "EnsLib.File.Passthrough",
        "EnsLib.REST.Service", "EnsLib.HTTP.Service",
        "EnsLib.TCP.CountedInboundAdapter",
        "EnsLib.RecordMap.Service", "EnsLib.EDI",
        "HS.FHIRServer.Interop.Service",
    ]
    cn = class_name.lower()
    if ".bs." in cn or cn.endswith("service"):
        return True
    for p in service_patterns:
        if p.lower() in cn:
            return True
    return False


def is_operation_class(class_name):
    """Heuristic to detect Business Operation classes."""
    operation_patterns = [
        "Operation", "EnsLib.HL7.Operation", "EnsLib.File.Passthrough",
        "EnsLib.REST.Operation", "EnsLib.HTTP.OutboundAdapter",
        "EnsLib.SQL.Operation", "HS.Hub.HSWS",
        "HS.FHIRServer.Interop.Operation",
    ]
    cn = class_name.lower()
    if ".bo." in cn or cn.endswith("operation"):
        return True
    for p in operation_patterns:
        if p.lower() in cn:
            return True
    # PassthroughService vs PassthroughOperation disambiguation
    if "passthroughoperation" in cn:
        return True
    return False


# ---------------------------------------------------------------------------
# Routing rule parsing
# ---------------------------------------------------------------------------

def parse_routing_rule(rule_xml):
    """Parse a routing rule XData and extract routes.

    Returns list of dicts: {condition, targets, transforms}
    """
    if not rule_xml:
        return []

    try:
        root = ET.fromstring(rule_xml)
    except ET.ParseError:
        return []

    routes = []
    # Handle namespace prefixes by searching locally
    for rule_elem in root.iter():
        if rule_elem.tag.endswith("rule") or rule_elem.tag == "rule":
            for when_elem in rule_elem:
                tag = when_elem.tag.split("}")[-1] if "}" in when_elem.tag else when_elem.tag
                if tag in ("when", "otherwise"):
                    condition = when_elem.get("condition", "(otherwise)")
                    if tag == "otherwise":
                        condition = "(otherwise)"
                    route_info = {"condition": condition, "targets": [], "transforms": []}
                    for send_elem in when_elem:
                        stag = send_elem.tag.split("}")[-1] if "}" in send_elem.tag else send_elem.tag
                        if stag == "send":
                            target = send_elem.get("target", "")
                            transform = send_elem.get("transform", "")
                            if target:
                                route_info["targets"].append(target)
                            if transform:
                                route_info["transforms"].append(transform)
                    routes.append(route_info)

    return routes


# ---------------------------------------------------------------------------
# BPL parsing
# ---------------------------------------------------------------------------

def parse_bpl(bpl_xml):
    """Parse a BPL XData and extract call targets.

    Returns list of target config names referenced in <call> activities.
    """
    if not bpl_xml:
        return []

    try:
        root = ET.fromstring(bpl_xml)
    except ET.ParseError:
        return []

    targets = []
    for elem in root.iter():
        tag = elem.tag.split("}")[-1] if "}" in elem.tag else elem.tag
        if tag == "call":
            target = elem.get("target", "")
            if target:
                targets.append(target)

    return list(dict.fromkeys(targets))  # deduplicate, preserve order


# ---------------------------------------------------------------------------
# Mermaid generation
# ---------------------------------------------------------------------------

def generate_mermaid(hosts, rule_routes, bpl_targets):
    """Generate Mermaid LR flowchart code.

    Args:
        hosts: dict from parse_production_xml
        rule_routes: dict mapping process_name -> list of route dicts
        bpl_targets: dict mapping process_name -> list of target names
    """
    lines = ["flowchart LR"]
    lines.append("")

    # Style classes
    lines.append("    classDef service fill:#d4edda,stroke:#28a745,color:#000")
    lines.append("    classDef process fill:#cce5ff,stroke:#007bff,color:#000")
    lines.append("    classDef operation fill:#ffe8cc,stroke:#fd7e14,color:#000")
    lines.append("    classDef disabled fill:#e2e3e5,stroke:#6c757d,color:#6c757d")
    lines.append("")

    # Collect all node IDs for styling
    service_ids = []
    process_ids = []
    operation_ids = []
    disabled_ids = []

    # Build a map of name -> host_info for lookups
    all_hosts = {}
    for htype in ("services", "processes", "operations"):
        for h in hosts[htype]:
            all_hosts[h["name"]] = h

    # -- Services --
    lines.append("    %% Business Services")
    for h in hosts["services"]:
        nid = sanitize_id(h["name"])
        label = h["name"].replace('"', '#quot;')
        short_class = h["class_name"].split(".")[-1] if "." in h["class_name"] else h["class_name"]
        lines.append(f'    {nid}["{label}<br/><small>{short_class}</small>"]')
        if h["enabled"]:
            service_ids.append(nid)
        else:
            disabled_ids.append(nid)

    lines.append("")

    # -- Processes --
    lines.append("    %% Business Processes")
    for h in hosts["processes"]:
        nid = sanitize_id(h["name"])
        label = h["name"].replace('"', '#quot;')
        short_class = h["class_name"].split(".")[-1] if "." in h["class_name"] else h["class_name"]
        lines.append(f'    {nid}{{{{"{label}<br/><small>{short_class}</small>"}}}}')
        if h["enabled"]:
            process_ids.append(nid)
        else:
            disabled_ids.append(nid)

    lines.append("")

    # -- Operations --
    lines.append("    %% Business Operations")
    for h in hosts["operations"]:
        nid = sanitize_id(h["name"])
        label = h["name"].replace('"', '#quot;')
        short_class = h["class_name"].split(".")[-1] if "." in h["class_name"] else h["class_name"]
        lines.append(f'    {nid}(["{label}<br/><small>{short_class}</small>"])')
        if h["enabled"]:
            operation_ids.append(nid)
        else:
            disabled_ids.append(nid)

    lines.append("")

    # -- Connections from TargetConfigNames --
    lines.append("    %% Message flow")
    edges_seen = set()

    for htype in ("services", "processes"):
        for h in hosts[htype]:
            src_id = sanitize_id(h["name"])
            for target in h["targets"]:
                tgt_id = sanitize_id(target)
                edge_key = (src_id, tgt_id, "")
                if edge_key not in edges_seen:
                    edges_seen.add(edge_key)
                    lines.append(f"    {src_id} --> {tgt_id}")

    lines.append("")

    # -- Connections from routing rules --
    for process_name, routes in rule_routes.items():
        src_id = sanitize_id(process_name)
        for route in routes:
            for i, target in enumerate(route["targets"]):
                tgt_id = sanitize_id(target)
                # Build label from transform name (short) + condition
                label_parts = []
                if i < len(route["transforms"]) and route["transforms"][i]:
                    dtl_short = route["transforms"][i].split(".")[-1]
                    label_parts.append(dtl_short)
                if route["condition"] and route["condition"] != "(otherwise)":
                    # Truncate long conditions
                    cond = route["condition"]
                    if len(cond) > 50:
                        cond = cond[:47] + "..."
                    label_parts.append(cond)
                elif route["condition"] == "(otherwise)":
                    label_parts.append("otherwise")

                edge_label = " | ".join(label_parts) if label_parts else ""
                edge_key = (src_id, tgt_id, edge_label)
                if edge_key not in edges_seen:
                    edges_seen.add(edge_key)
                    if edge_label:
                        safe_label = edge_label.replace('"', '#quot;')
                        lines.append(f'    {src_id} -->|"{safe_label}"| {tgt_id}')
                    else:
                        # Avoid duplicate plain arrows if already drawn
                        plain_key = (src_id, tgt_id, "")
                        if plain_key not in edges_seen:
                            edges_seen.add(plain_key)
                            lines.append(f"    {src_id} --> {tgt_id}")

    # -- Connections from BPL call targets --
    for process_name, targets in bpl_targets.items():
        src_id = sanitize_id(process_name)
        for target in targets:
            tgt_id = sanitize_id(target)
            edge_key = (src_id, tgt_id, "")
            if edge_key not in edges_seen:
                edges_seen.add(edge_key)
                lines.append(f"    {src_id} --> {tgt_id}")

    lines.append("")

    # -- Apply styles --
    if service_ids:
        lines.append(f"    class {','.join(service_ids)} service")
    if process_ids:
        lines.append(f"    class {','.join(process_ids)} process")
    if operation_ids:
        lines.append(f"    class {','.join(operation_ids)} operation")
    if disabled_ids:
        lines.append(f"    class {','.join(disabled_ids)} disabled")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = common_arg_parser("Generate a Mermaid diagram of a production's message flow")
    parser.add_argument("--package", "--pkg", required=True,
                        help="Production package name (e.g., Demo.VaccineToASIIS)")
    parser.add_argument("--local", action="store_true",
                        help="Read from local src/ instead of pulling from server")
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    package = args.package
    production_class = f"{package}.Production"
    doc_name = f"{production_class}.cls"

    # -- 1. Get production source --
    cls_text = None

    if args.local:
        # Try local file
        script_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))
        # Convert package to path: Demo.VaccineToASIIS -> Demo/VaccineToASIIS
        pkg_path = package.replace(".", "/")
        local_path = os.path.join(project_root, "src", args.namespace, pkg_path, "Production.cls")
        if os.path.isfile(local_path):
            with open(local_path, "r", encoding="utf-8") as f:
                cls_text = f.read()
            print(f"Read production from {local_path}", file=sys.stderr)
        else:
            print(f"ERROR: Local file not found: {local_path}", file=sys.stderr)
            sys.exit(1)
    else:
        _, base_url, username, password = get_server_and_creds(args)
        cls_text = fetch_document(base_url, args.namespace, username, password, doc_name)
        if cls_text is None:
            print(f"ERROR: Could not fetch {doc_name} from server", file=sys.stderr)
            sys.exit(1)
        print(f"Pulled {doc_name} from server", file=sys.stderr)

    # -- 2. Parse production XML --
    prod_xml = extract_xdata_xml(cls_text)
    if prod_xml is None:
        print("ERROR: Could not find XData ProductionDefinition in the production class", file=sys.stderr)
        sys.exit(1)

    hosts = parse_production_xml(prod_xml)

    svc_count = len(hosts["services"])
    bp_count = len(hosts["processes"])
    bo_count = len(hosts["operations"])
    print(f"Found {svc_count} service(s), {bp_count} process(es), {bo_count} operation(s)", file=sys.stderr)

    # -- 3. Resolve routing rules and BPLs --
    rule_routes = {}
    bpl_call_targets = {}

    if not args.local:
        for h in hosts["processes"]:
            class_name = h["class_name"]

            # Check if it's a routing engine — pull its rule class
            if "RoutingEngine" in class_name or "MsgRouter" in class_name:
                # The routing rule class is typically in the settings as "BusinessRuleName"
                rule_class = h["settings"].get("BusinessRuleName", "")
                if rule_class:
                    rule_doc = f"{rule_class}.cls"
                    rule_text = fetch_document(base_url, args.namespace, username, password, rule_doc)
                    if rule_text:
                        rule_xml = extract_xdata_block(rule_text, "RuleDefinition")
                        routes = parse_routing_rule(rule_xml)
                        if routes:
                            rule_routes[h["name"]] = routes
                            print(f"Parsed routing rule: {rule_class} ({len(routes)} route(s))", file=sys.stderr)

            # Check if it's a BPL — try pulling the class to look for BPL XData
            elif "BPL" in class_name or ".BPL." in class_name:
                bpl_doc = f"{class_name}.cls"
                bpl_text = fetch_document(base_url, args.namespace, username, password, bpl_doc)
                if bpl_text:
                    bpl_xml = extract_xdata_block(bpl_text, "BPL")
                    targets = parse_bpl(bpl_xml)
                    if targets:
                        bpl_call_targets[h["name"]] = targets
                        print(f"Parsed BPL: {class_name} ({len(targets)} target(s))", file=sys.stderr)

    # -- 4. Generate Mermaid --
    mermaid = generate_mermaid(hosts, rule_routes, bpl_call_targets)
    print(mermaid)

    # -- 5. Summary counts (to stderr so they don't mix with mermaid output) --
    disabled_count = sum(1 for h in hosts["services"] + hosts["processes"] + hosts["operations"]
                         if not h.get("enabled", True))
    rule_count = sum(len(routes) for routes in rule_routes.values())
    print(f"\nSummary: {svc_count} services, {bp_count} processes, {bo_count} operations"
          f" | {rule_count} routing rule targets resolved"
          f" | {disabled_count} disabled", file=sys.stderr)


if __name__ == "__main__":
    main()
