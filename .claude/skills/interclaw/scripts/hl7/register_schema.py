#!/usr/bin/env python3
"""Register a custom HL7 schema on an IRIS server via the Atelier API.

Reads a .HL7 XML file and sets the ^EnsHL7.Schema globals directly
using a temporary installer class pushed and executed via the API.

Usage:
    python register_schema.py --server myserver --namespace CLAUDE --input schema.HL7
"""
import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import argparse
import json
import os
import sys
import xml.etree.ElementTree as ET

from iris_api import common_arg_parser, get_server_and_creds, make_request


def parse_hl7_schema(filepath):
    """Parse a .HL7 XML schema file and extract components."""
    tree = ET.parse(filepath)
    root = tree.getroot()

    schema = {
        "name": root.get("name"),
        "description": root.get("description", ""),
        "base": root.get("base", "2.5.1"),
        "message_types": {},
        "message_structures": {},
        "segment_structures": {},
    }

    for mt in root.findall("MessageType"):
        schema["message_types"][mt.get("name")] = {
            "structure": mt.get("structure"),
            "returntype": mt.get("returntype", "ACK"),
        }

    for ms in root.findall("MessageStructure"):
        schema["message_structures"][ms.get("name")] = ms.get("definition")

    for ss in root.findall("SegmentStructure"):
        fields = []
        for sub in ss.findall("SegmentSubStructure"):
            fields.append({
                "piece": int(sub.get("piece")),
                "datatype": sub.get("datatype", "ST"),
                "required": sub.get("required", "O"),
                "max_length": sub.get("max_length", "200"),
                "description": sub.get("description", ""),
            })
        schema["segment_structures"][ss.get("name")] = {
            "description": ss.get("description", ""),
            "fields": fields,
        }

    return schema


def generate_installer_code(schema):
    """Generate ObjectScript lines that set ^EnsHL7.Schema globals."""
    name = schema["name"]
    lines = []

    lines.append(f'Set ^EnsHL7.Schema("{name}","base") = "{schema["base"]}"')
    lines.append(f'Set ^EnsHL7.Schema("{name}","description") = "{schema["description"]}"')

    for mt_name, mt in schema["message_types"].items():
        lines.append(f'Set ^EnsHL7.Schema("{name}","MT","{mt_name}") = "{mt["structure"]},{mt["returntype"]}"')

    for ms_name, definition in schema["message_structures"].items():
        lines.append(f'Set ^EnsHL7.Schema("{name}","MS","{ms_name}") = "{definition}"')

    for ss_name, ss in schema["segment_structures"].items():
        lines.append(f'Set ^EnsHL7.Schema("{name}","SS","{ss_name}") = ""')
        for field in ss["fields"]:
            piece = field["piece"]
            dt = field["datatype"]
            req = field["required"]
            maxlen = field["max_length"]
            desc = field["description"]
            lines.append(f'Set ^EnsHL7.Schema("{name}","SS","{ss_name}",{piece}) = "{dt},{req},,{maxlen},,,{desc}"')

    return lines


def install_schema(base_url, username, password, namespace, schema):
    """Install schema by pushing a temporary class and executing it."""
    name = schema["name"]
    lines = generate_installer_code(schema)

    # Build a temporary class
    method_body = "\n    ".join(lines)
    cls_content = f"""Class {name}.SchemaInstaller Extends %RegisteredObject
{{

ClassMethod Install() As %Status [ SqlProc ]
{{
    {method_body}
    Return $$$OK
}}

}}
"""
    # Push the installer class
    doc_name = f"{name}.SchemaInstaller.cls"
    content_lines = cls_content.split("\n")
    put_data = {"enc": False, "content": content_lines}

    url = f"{base_url}v1/{namespace}/doc/{doc_name}"
    try:
        make_request(url, username, password, method="PUT", data=put_data)
    except Exception:
        # Delete and retry on conflict
        try:
            make_request(url, username, password, method="DELETE")
        except Exception:
            pass
        make_request(url, username, password, method="PUT", data=put_data)

    # Compile
    compile_url = f"{base_url}v1/{namespace}/action/compile"
    make_request(compile_url, username, password, method="POST", data=[doc_name])

    # Execute via SQL
    sql = f"SELECT {name.replace('.', '_')}.SchemaInstaller_Install()"
    query_url = f"{base_url}v1/{namespace}/action/query"
    make_request(query_url, username, password, method="POST", data={"query": sql})

    # Clean up installer class
    try:
        make_request(url, username, password, method="DELETE")
    except Exception:
        pass

    return True


def main():
    parser = common_arg_parser(description="Register a custom HL7 schema on IRIS")
    parser.add_argument("--input", required=True, help="Path to .HL7 schema XML file")
    args = parser.parse_args()

    _, base_url, username, password = get_server_and_creds(args)
    schema = parse_hl7_schema(args.input)

    print(f"Registering schema '{schema['name']}' (base: {schema['base']}) in {args.namespace}...")
    print(f"  Message types: {len(schema['message_types'])}")
    print(f"  Message structures: {len(schema['message_structures'])}")
    print(f"  Segment structures: {len(schema['segment_structures'])}")

    try:
        install_schema(base_url, username, password, args.namespace, schema)
        print(f"OK: Schema '{schema['name']}' registered successfully")
    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
