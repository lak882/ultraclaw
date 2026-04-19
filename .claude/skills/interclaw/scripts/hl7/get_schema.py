#!/usr/bin/env python3
"""Pull HL7 schema information from an IRIS server.

Fetches the entire HL7 schema as a single XML document via the Atelier doc API
(GET /doc/{category}.HL7) and parses it locally. One fetch gives you everything:
message structures with group names, segment fields, data type subcomponents,
code tables.

Modes:
  --list-categories             List available schema categories (e.g., 2.5.1)
  --list-messages <cat>         List message structures in a category
  --list-segments <cat>         List segments in a category
  --message <cat:type>          Show full message structure with group tree + segment fields
  --segment <cat:seg>           Show segment field definitions (e.g., 2.5.1:PID)
  --segment <cat:seg> --fields  Show only top-level fields (no subcomponents)
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import json
import sys
import os
import xml.etree.ElementTree as ET

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import (common_arg_parser, get_server_and_creds, make_request,
                      parse_atelier_response, AtelierError)


# ---------------------------------------------------------------------------
# Schema fetching
# ---------------------------------------------------------------------------

def fetch_schema_xml(base_url, namespace, username, password, category):
    """Fetch the HL7 schema XML document for a category (e.g., '2.5.1').

    Returns an ElementTree root element.
    """
    url = f"{base_url}/v1/{namespace}/doc/{category}.HL7"
    status, body = make_request(url, username, password, timeout=30)

    if status is None:
        print(f"ERROR: Could not reach server - {body}", file=sys.stderr)
        sys.exit(1)
    if status == 404:
        print(f"ERROR: Schema '{category}.HL7' not found in {namespace}", file=sys.stderr)
        sys.exit(1)
    if status == 401:
        print("ERROR: Authentication failed (401)", file=sys.stderr)
        sys.exit(1)
    if status != 200:
        print(f"ERROR: Unexpected status {status}", file=sys.stderr)
        sys.exit(1)

    try:
        content = parse_atelier_response(body)
    except AtelierError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)

    xml_text = "\n".join(str(line) for line in content)
    return ET.fromstring(xml_text)


def run_sql(base_url, namespace, username, password, sql):
    """Execute a SQL query (used only for --list-categories)."""
    url = f"{base_url}/v1/{namespace}/action/query"
    status, body = make_request(url, username, password, method="POST",
                                data={"query": sql})
    if status is None:
        print(f"ERROR: Could not reach server - {body}", file=sys.stderr)
        sys.exit(1)
    if status != 200:
        print(f"ERROR: Query failed with status {status}", file=sys.stderr)
        sys.exit(1)
    try:
        content = parse_atelier_response(body)
    except AtelierError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)

    rows = []
    if isinstance(content, list):
        for item in content:
            if isinstance(item, dict) and "content" not in item:
                rows.append(item)
    return rows


# ---------------------------------------------------------------------------
# XML parsing helpers
# ---------------------------------------------------------------------------

def build_segment_map(root):
    """Build dict: segment_name -> list of field dicts from SegmentStructure elements."""
    segments = {}
    for seg in root.findall("SegmentStructure"):
        name = seg.get("name")
        fields = []
        for sub in seg.findall("SegmentSubStructure"):
            fields.append({
                "piece": int(sub.get("piece", 0)),
                "description": sub.get("description", ""),
                "datatype": sub.get("datatype", ""),
                "max_length": sub.get("max_length", ""),
                "required": sub.get("required", "O"),
                "repeating": sub.get("ifrepeating", "0") == "1",
            })
        segments[name] = fields
    return segments


def build_datatype_map(root):
    """Build dict: datatype_name -> list of component dicts from DataType elements."""
    datatypes = {}
    for dt in root.findall("DataType"):
        name = dt.get("name")
        components = []
        for sub in dt.findall("DataSubType"):
            components.append({
                "piece": int(sub.get("piece", 0)),
                "description": sub.get("description", ""),
                "datatype": sub.get("datatype", ""),
                "max_length": sub.get("max_length", ""),
                "required": sub.get("required", "O"),
            })
        datatypes[name] = components
    return datatypes


def build_message_structure_map(root):
    """Build dict: msg_name -> {definition, description}."""
    structures = {}
    # Get descriptions from MessageType elements
    descriptions = {}
    for mt in root.findall("MessageType"):
        name = mt.get("name", "")
        desc = mt.get("description", "")
        structure = mt.get("structure", "")
        if structure:
            descriptions[structure] = desc

    for ms in root.findall("MessageStructure"):
        name = ms.get("name")
        defn = ms.get("definition", "")
        desc = descriptions.get(name, "")
        structures[name] = {"definition": defn, "description": desc}
    return structures


# ---------------------------------------------------------------------------
# Message definition parser — turns definition string into a tree with group names
# ---------------------------------------------------------------------------

def parse_message_definition(definition):
    """Parse 'MSH~[~{~SFT~}~]~PID~...' into a tree structure.

    Returns list of nodes. Each node is a dict with:
      - name: segment name or group name (e.g., 'ORCgrp')
      - type: 'segment' or 'group'
      - optional: bool
      - repeating: bool
      - children: list of nodes (for groups only)
    """
    tokens = [t for t in definition.split("~") if t]
    nodes, _ = _parse_tokens(tokens, 0)
    return nodes


def _parse_tokens(tokens, pos):
    """Recursive token parser. Returns (nodes, new_pos)."""
    nodes = []
    name_counts = {}

    while pos < len(tokens):
        token = tokens[pos]

        # End of group
        if token in ("]", "}", ")"):
            pos += 1
            break

        # Start of group
        if token in ("[", "{", "("):
            optional = token in ("[", "(")
            repeating = token in ("{",)
            pos += 1
            children, pos = _parse_tokens(tokens, pos)

            if len(children) == 1 and children[0]["type"] == "segment":
                # Single segment in wrapper — collapse, just add flags
                node = children[0]
                if optional:
                    node["optional"] = True
                if repeating:
                    node["repeating"] = True
                _track_name(name_counts, node["name"], node)
                nodes.append(node)
            elif len(children) == 1 and children[0]["type"] == "group":
                # Single group child — merge optional/repeating flags up
                # This handles [~{~...~}~] → single group that is both optional and repeating
                node = children[0]
                if optional:
                    node["optional"] = True
                if repeating:
                    node["repeating"] = True
                _track_name(name_counts, node["name"], node)
                nodes.append(node)
            elif len(children) > 0:
                # Multi-segment group — name after first segment
                first_seg = _first_segment_name(children)
                group_name = first_seg + "grp" if first_seg else "grp"
                node = {
                    "name": group_name,
                    "type": "group",
                    "optional": optional,
                    "repeating": repeating,
                    "children": children,
                }
                _track_name(name_counts, group_name, node)
                nodes.append(node)
            continue

        # Choice group markers (< > |) — treat segments between | as alternatives
        if token == "<":
            pos += 1
            children, pos = _parse_choice(tokens, pos)
            if children:
                first_seg = _first_segment_name(children)
                group_name = first_seg + "union" if first_seg else "union"
                node = {
                    "name": group_name,
                    "type": "group",
                    "optional": False,
                    "repeating": False,
                    "children": children,
                }
                nodes.append(node)
            continue

        # Regular segment
        node = {
            "name": token,
            "type": "segment",
            "optional": False,
            "repeating": False,
        }
        _track_name(name_counts, token, node)
        nodes.append(node)
        pos += 1

    return nodes, pos


def _parse_choice(tokens, pos):
    """Parse a choice group <SEG1|SEG2|SEG3> — returns list of segment nodes."""
    nodes = []
    while pos < len(tokens):
        token = tokens[pos]
        if token == ">":
            pos += 1
            break
        if token == "|":
            pos += 1
            continue
        nodes.append({
            "name": token,
            "type": "segment",
            "optional": False,
            "repeating": False,
        })
        pos += 1
    return nodes, pos


def _first_segment_name(children):
    """Get the name of the first segment in a list of nodes."""
    for child in children:
        if child["type"] == "segment":
            return child["name"]
        if child["type"] == "group" and child.get("children"):
            result = _first_segment_name(child["children"])
            if result:
                return result
    return ""


def _track_name(name_counts, name, node):
    """Track duplicate names at the same level, appending i2, i3 etc."""
    base = name.rstrip("grp").rstrip("union") if name.endswith(("grp", "union")) else name
    name_counts[base] = name_counts.get(base, 0) + 1
    if name_counts[base] > 1:
        node["name"] = name + "i" + str(name_counts[base])


# ---------------------------------------------------------------------------
# Virtual document path computation
# ---------------------------------------------------------------------------

def compute_segment_paths(nodes, prefix=""):
    """Walk the tree and compute virtual document paths for each segment.

    Returns dict: segment_name -> path (e.g., 'ORC' -> 'ORCgrp().ORC')
    """
    paths = {}
    for node in nodes:
        if node["type"] == "segment":
            seg_name = node["name"]
            rep = "()" if node["repeating"] else ""
            if prefix:
                path = f"{prefix}.{seg_name}{rep}"
            else:
                path = f"{seg_name}{rep}"
            paths[seg_name] = path
        elif node["type"] == "group":
            grp_name = node["name"]
            rep = "()" if node["repeating"] else ""
            new_prefix = f"{prefix}.{grp_name}{rep}" if prefix else f"{grp_name}{rep}"
            child_paths = compute_segment_paths(node.get("children", []), new_prefix)
            paths.update(child_paths)
    return paths


# ---------------------------------------------------------------------------
# Display functions
# ---------------------------------------------------------------------------

def print_structure_tree(nodes, indent=2):
    """Print the message structure tree."""
    for node in nodes:
        flags = []
        if node.get("optional"):
            flags.append("optional")
        if node.get("repeating"):
            flags.append("repeating")
        flag_str = f" ({', '.join(flags)})" if flags else ""

        prefix = " " * indent
        print(f"{prefix}{node['name']}{flag_str}")

        if node["type"] == "group" and node.get("children"):
            print_structure_tree(node["children"], indent + 2)


def _is_primitive(datatype, datatypes):
    """Check if a datatype is primitive (not composite or has only 1 trivial sub)."""
    if datatype not in datatypes:
        return True
    components = datatypes[datatype]
    if len(components) <= 1:
        return True
    return False


def print_segment_fields(seg_name, fields, datatypes, path=None, top_level_only=False):
    """Print field definitions for a segment."""
    header = f"--- {seg_name}"
    if path and path != seg_name:
        header += f" (path: {path})"
    header += " ---"
    print(header)

    for field in fields:
        rep = " (repeating)" if field["repeating"] else ""
        print(f"  {field['piece']:<4} {field['description']:<40} {field['datatype']:<5} {field['required']}{rep}")

        if not top_level_only and not _is_primitive(field["datatype"], datatypes):
            components = datatypes[field["datatype"]]
            for comp in components:
                print(f"         .{comp['piece']:<3} {comp['description']:<36} {comp['datatype']}")
                # Show sub-subcomponents only if the component datatype is also composite
                if not _is_primitive(comp["datatype"], datatypes):
                    for sub in datatypes[comp["datatype"]]:
                        print(f"              .{sub['piece']:<3} {sub['description']:<31} {sub['datatype']}")
    print()


def build_json_output(msg_name, description, nodes, segment_paths, segments, datatypes):
    """Build a JSON-serializable dict with full message schema info."""
    result = {
        "message": msg_name,
        "description": description,
        "structure": _nodes_to_json(nodes),
        "segments": {},
    }

    # Collect all segment names from the tree
    all_segs = _collect_segment_names(nodes)

    for seg_name in all_segs:
        if seg_name not in segments:
            continue
        seg_data = {
            "path": segment_paths.get(seg_name, seg_name),
            "fields": [],
        }
        for field in segments[seg_name]:
            field_data = {
                "piece": field["piece"],
                "name": field["description"],
                "datatype": field["datatype"],
                "required": field["required"],
                "repeating": field["repeating"],
            }
            if field["datatype"] in datatypes:
                field_data["components"] = []
                for comp in datatypes[field["datatype"]]:
                    comp_data = {
                        "piece": comp["piece"],
                        "name": comp["description"],
                        "datatype": comp["datatype"],
                    }
                    if comp["datatype"] in datatypes:
                        comp_data["subcomponents"] = [
                            {"piece": s["piece"], "name": s["description"], "datatype": s["datatype"]}
                            for s in datatypes[comp["datatype"]]
                        ]
                    field_data["components"].append(comp_data)
            seg_data["fields"].append(field_data)
        result["segments"][seg_name] = seg_data

    return result


def _nodes_to_json(nodes):
    """Convert tree nodes to JSON-serializable list."""
    result = []
    for node in nodes:
        item = {
            "name": node["name"],
            "type": node["type"],
            "optional": node.get("optional", False),
            "repeating": node.get("repeating", False),
        }
        if node["type"] == "group" and node.get("children"):
            item["children"] = _nodes_to_json(node["children"])
        result.append(item)
    return result


def _collect_segment_names(nodes):
    """Collect all segment names from the tree in order."""
    names = []
    for node in nodes:
        if node["type"] == "segment":
            names.append(node["name"])
        elif node["type"] == "group" and node.get("children"):
            names.extend(_collect_segment_names(node["children"]))
    return names


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = common_arg_parser("Pull HL7 schema information from IRIS")

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--list-categories", action="store_true",
                       help="List available HL7 schema categories (e.g., 2.5.1)")
    group.add_argument("--list-messages",
                       help="List message structures in a category (e.g., 2.5.1)")
    group.add_argument("--list-segments",
                       help="List segments in a category (e.g., 2.5.1)")
    group.add_argument("--message", "-m",
                       help="Show full message structure with group tree and segment fields (e.g., 2.5.1:VXU_V04)")
    group.add_argument("--segment", "-g",
                       help="Show segment field definitions (e.g., 2.5.1:PID)")

    parser.add_argument("--fields", action="store_true",
                        help="Show only top-level fields (no subcomponents)")
    parser.add_argument("--json", action="store_true",
                        help="Output as JSON")

    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    _, base_url, username, password = get_server_and_creds(args)

    # --list-categories still uses SQL (we don't know which .HL7 docs exist)
    if args.list_categories:
        rows = run_sql(base_url, args.namespace, username, password,
                       "SELECT Category, Description, IsStandard FROM EnsLib_HL7.Schema_TypeCategories()")
        if args.json:
            print(json.dumps(rows, indent=2))
        else:
            print(f"{'Category':<15} {'Description':<50} {'Standard'}")
            print(f"{'-'*14}  {'-'*49} {'-'*8}")
            for r in rows:
                print(f"{r.get('Category',''):<15} {r.get('Description',''):<50} {r.get('IsStandard','')}")
            print(f"\n{len(rows)} category(ies)", file=sys.stderr)
        return

    # All other modes fetch the schema XML
    if args.list_messages:
        category = args.list_messages
    elif args.list_segments:
        category = args.list_segments
    elif args.message:
        if ":" not in args.message:
            parser.error("--message requires format category:type (e.g., 2.5.1:VXU_V04)")
        category = args.message.split(":")[0]
    elif args.segment:
        if ":" not in args.segment:
            parser.error("--segment requires format category:segment (e.g., 2.5.1:PID)")
        category = args.segment.split(":")[0]

    root = fetch_schema_xml(base_url, args.namespace, username, password, category)
    segments = build_segment_map(root)
    datatypes = build_datatype_map(root)
    msg_structures = build_message_structure_map(root)

    # --list-messages
    if args.list_messages:
        if args.json:
            print(json.dumps([{"name": k, "description": v["description"]}
                              for k, v in sorted(msg_structures.items())], indent=2))
        else:
            print(f"{'MessageStructure':<30} {'Description'}")
            print(f"{'-'*29}  {'-'*50}")
            for name in sorted(msg_structures):
                desc = msg_structures[name]["description"]
                print(f"{category}:{name:<28} {desc}")
            print(f"\n{len(msg_structures)} message structure(s) in {category}", file=sys.stderr)
        return

    # --list-segments
    if args.list_segments:
        if args.json:
            print(json.dumps([{"name": k, "field_count": len(v)}
                              for k, v in sorted(segments.items())], indent=2))
        else:
            print(f"{'Segment':<10} {'Fields'}")
            print(f"{'-'*9}  {'-'*6}")
            for name in sorted(segments):
                print(f"{name:<10} {len(segments[name])}")
            print(f"\n{len(segments)} segment(s) in {category}", file=sys.stderr)
        return

    # --message: full message structure with tree + segment fields
    if args.message:
        msg_name = args.message.split(":", 1)[1]
        if msg_name not in msg_structures:
            print(f"ERROR: Message structure '{msg_name}' not found in category '{category}'", file=sys.stderr)
            print(f"Use --list-messages {category} to see available structures", file=sys.stderr)
            sys.exit(1)

        ms = msg_structures[msg_name]
        nodes = parse_message_definition(ms["definition"])
        segment_paths = compute_segment_paths(nodes)

        if args.json:
            output = build_json_output(msg_name, ms["description"], nodes,
                                       segment_paths, segments, datatypes)
            print(json.dumps(output, indent=2))
            return

        # Text output
        print(f"=== {category}:{msg_name} ===")
        if ms["description"]:
            print(ms["description"])
        print()

        print("Structure:")
        print_structure_tree(nodes)
        print()

        print("Segment Fields:")
        all_segs = _collect_segment_names(nodes)
        for seg_name in all_segs:
            if seg_name in segments:
                path = segment_paths.get(seg_name, seg_name)
                print_segment_fields(seg_name, segments[seg_name], datatypes,
                                     path=path, top_level_only=args.fields)

        print(f"{len(all_segs)} segment(s) in message structure", file=sys.stderr)
        return

    # --segment: standalone segment view
    if args.segment:
        parts = args.segment.split(":")
        seg_name = parts[1]

        if seg_name not in segments:
            print(f"ERROR: Segment '{seg_name}' not found in category '{category}'", file=sys.stderr)
            sys.exit(1)

        if args.json:
            fields_out = []
            for f in segments[seg_name]:
                fd = {
                    "piece": f["piece"],
                    "name": f["description"],
                    "datatype": f["datatype"],
                    "required": f["required"],
                    "repeating": f["repeating"],
                }
                if f["datatype"] in datatypes:
                    fd["components"] = [
                        {"piece": c["piece"], "name": c["description"], "datatype": c["datatype"]}
                        for c in datatypes[f["datatype"]]
                    ]
                fields_out.append(fd)
            print(json.dumps({"segment": seg_name, "fields": fields_out}, indent=2))
            return

        print(f"=== {category}:{seg_name} Segment Fields ===")
        if args.fields:
            print("(top-level fields only)\n")
        print_segment_fields(seg_name, segments[seg_name], datatypes,
                             top_level_only=args.fields)
        print(f"{len(segments[seg_name])} field(s)", file=sys.stderr)


if __name__ == "__main__":
    main()
