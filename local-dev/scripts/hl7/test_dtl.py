#!/usr/bin/env python3
"""Test a DTL transformation against a sample HL7 message.

Uses the InteropEditors REST API (v3) TestDTL endpoint.

Usage:
  # Test with a message file
  test_dtl.py --server myserver --namespace CLAUDE --dtl Demo.DTL.FacilityLookup --input sample.hl7

  # Generate a sample VXU_V04 message and test
  test_dtl.py --server myserver --namespace CLAUDE --dtl Demo.DTL.FacilityLookup --generate VXU_V04

  # Show only specific segments in output
  test_dtl.py --server myserver --namespace CLAUDE --dtl Demo.DTL.FacilityLookup --input sample.hl7 --show ORC,RXA

  # Show diff between source and target
  test_dtl.py --server myserver --namespace CLAUDE --dtl Demo.DTL.FacilityLookup --input sample.hl7 --diff
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import datetime
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import (common_arg_parser, get_server_and_creds,
                      build_interop_url, make_interop_request)

# Sample HL7 message templates keyed by message structure
SAMPLE_MESSAGES = {
    "VXU_V04": (
        "MSH|^~\\&|VACCINESYS|SIICLIENT44678|ASIIS|AZDHS|{timestamp}||VXU^V04^VXU_V04|{control_id}|P|2.5.1|||AL|NE|||||Z22^CDCPHINVS\r"
        "PID|1||123456^^^SIICLIENT44678^MR||DOE^JANE^M||19850315|F|||123 MAIN ST^^PHOENIX^AZ^85001||^PRN^PH^^^602^5551234\r"
        "PD1|||CONGRESS PEDIATRICS^^12345|1234567890^SMITH^JOHN^A^^DR\r"
        "NK1|1|DOE^JOHN|FTH^Father|123 MAIN ST^^PHOENIX^AZ^85001|^PRN^PH^^^602^5551234\r"
        "ORC|RE|12345^VACCINESYS|67890^ASIIS|||||||1234567890^SMITH^JOHN^A^^DR||1234567890^SMITH^JOHN^A^^DR|SIICLIENT44678^CONGRESS PEDIATRICS^^^SIICLIENT44678||||CONGRESS PEDIATRICS\r"
        "RXA|0|1|{date}|{date}|141^Influenza^CVX|0.5|mL^milliliter^UCUM||00^Administered^NIP001|1234567890^SMITH^JOHN^A^^DR|SIICLIENT44678^CONGRESS PEDIATRICS^^^SIICLIENT44678||||12345|20261231|SKB^GlaxoSmithKline^MVX|||CP|A\r"
        "RXR|C28161^IM^NCIT|LD^Left Deltoid^HL70163\r"
        "OBX|1|CE|64994-7^Eligibility Status^LN|1|V02^VFC Eligible Medicaid/Medicaid Managed Care^HL70064||||||F|||{date}\r"
        "OBX|2|CE|30956-7^Vaccine Type^LN|2|141^Influenza^CVX||||||F|||{date}"
    ),
    "ADT_A01": (
        "MSH|^~\\&|ADTSYS|FACILITY|RECEIVER|DEST|{timestamp}||ADT^A01^ADT_A01|{control_id}|P|2.5.1|||AL|NE\r"
        "EVN|A01|{timestamp}\r"
        "PID|1||MRN12345^^^FACILITY^MR||DOE^JOHN^M||19700101|M|||456 OAK AVE^^PHOENIX^AZ^85004||^PRN^PH^^^602^5559876\r"
        "PV1|1|I|ICU^101^A^^^FACILITY||||1234567890^ATTENDING^DOC^A^^DR|||MED||||ADM|||1234567890^ATTENDING^DOC^A^^DR|IP||||||||||||||||||FACILITY|||||{date}"
    ),
    "ORM_O01": (
        "MSH|^~\\&|ORDERSYS|FACILITY|LAB|LABFAC|{timestamp}||ORM^O01^ORM_O01|{control_id}|P|2.5.1|||AL|NE\r"
        "PID|1||MRN12345^^^FACILITY^MR||DOE^JOHN^M||19700101|M\r"
        "ORC|NW|ORD123^ORDERSYS|||||^^^{date}^^R\r"
        "OBR|1|ORD123^ORDERSYS||80053^CMP^L|||{date}||||||||1234567890^ORDERING^DOC^A^^DR"
    ),
    "ORU_R01": (
        "MSH|^~\\&|LABSYS|LABFAC|RECEIVER|FACILITY|{timestamp}||ORU^R01^ORU_R01|{control_id}|P|2.5.1|||AL|NE\r"
        "PID|1||MRN12345^^^FACILITY^MR||DOE^JOHN^M||19700101|M\r"
        "OBR|1|ORD123^ORDERSYS|LAB456^LABSYS|80053^CMP^L|||{date}|||||||{date}||1234567890^ORDERING^DOC^A^^DR||||||{date}|||F\r"
        "OBX|1|NM|2345-7^Glucose^LN||95|mg/dL|74-106||||F|||{date}\r"
        "OBX|2|NM|2160-0^Creatinine^LN||1.1|mg/dL|0.7-1.3||||F|||{date}"
    ),
}


def generate_sample(message_type):
    """Generate a sample HL7 message for the given message structure."""
    template = SAMPLE_MESSAGES.get(message_type)
    if template is None:
        available = ", ".join(sorted(SAMPLE_MESSAGES.keys()))
        print(f"ERROR: No sample template for '{message_type}'. Available: {available}",
              file=sys.stderr)
        sys.exit(1)

    now = datetime.datetime.now()
    return template.format(
        timestamp=now.strftime("%Y%m%d%H%M%S"),
        date=now.strftime("%Y%m%d"),
        control_id=f"TEST{now.strftime('%Y%m%d%H%M%S')}",
    )


def run_test_dtl(interop_url, username, password, dtl_class, hl7_raw):
    """Call the InteropEditors TestDTL endpoint.

    Returns the raw transformed message string, or exits on error.
    """
    url = f"{interop_url}/dtl/test/{dtl_class}"
    status, body = make_interop_request(url, username, password, method="POST",
                                         query_params={"inputMessage": hl7_raw},
                                         timeout=30)
    if status != 200:
        error = body.get("summary", str(body)) if isinstance(body, dict) else str(body)
        print(f"ERROR: DTL test failed (status {status}): {error}", file=sys.stderr)
        sys.exit(1)

    raw = body.get("raw", "")
    if not raw:
        print("ERROR: DTL test returned empty result", file=sys.stderr)
        sys.exit(1)

    return raw


def parse_segments(hl7_text):
    """Parse HL7 text into a list of (segment_name, full_line) tuples."""
    segments = []
    for line in re.split(r'[\r\n]+', hl7_text):
        line = line.strip()
        if line:
            seg_name = line[:3] if len(line) >= 3 else line
            segments.append((seg_name, line))
    return segments


def show_message(label, hl7_text, filter_segments=None):
    """Display an HL7 message with optional segment filtering."""
    print(f"\n=== {label} ===")
    segments = parse_segments(hl7_text)
    for seg_name, line in segments:
        if filter_segments is None or seg_name in filter_segments:
            print(line)


def show_diff(source_text, target_text):
    """Show a simple diff between source and target HL7 messages."""
    source_segs = parse_segments(source_text)
    target_segs = parse_segments(target_text)

    print("\n=== DIFF (source > target) ===")
    max_segs = max(len(source_segs), len(target_segs))
    changes = 0
    for i in range(max_segs):
        s_name, s_line = source_segs[i] if i < len(source_segs) else ("", "")
        t_name, t_line = target_segs[i] if i < len(target_segs) else ("", "")

        if s_line != t_line:
            changes += 1
            print(f"  - {s_line}")
            print(f"  + {t_line}")

    if changes == 0:
        print("  (no differences)")
    else:
        print(f"\n{changes} segment(s) changed")


def main():
    parser = common_arg_parser("Test a DTL transformation against a sample HL7 message")
    parser.add_argument("--dtl", "-d", required=True,
                        help="DTL class name (e.g., Demo.VaccineToASIIS.DTL.FacilityLookup)")
    parser.add_argument("--input", "-i",
                        help="Input HL7 message file")
    parser.add_argument("--generate", "-g", metavar="MSG_TYPE",
                        help="Generate a sample message (e.g., VXU_V04, ADT_A01, ORU_R01)")
    parser.add_argument("--show", metavar="SEGS",
                        help="Only show these segments in output (comma-separated, e.g., ORC,RXA)")
    parser.add_argument("--diff", action="store_true",
                        help="Show diff between source and target")
    parser.add_argument("--raw", action="store_true",
                        help="Output raw transformed message only (for piping)")
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    if not args.input and not args.generate:
        parser.error("Specify --input <file> or --generate <MSG_TYPE>")

    server_config, _, username, password = get_server_and_creds(args)
    interop_url = build_interop_url(server_config, args.namespace)

    # Load or generate the source message
    if args.input:
        if not os.path.exists(args.input):
            print(f"ERROR: File not found: {args.input}", file=sys.stderr)
            sys.exit(1)
        with open(args.input, "r", encoding="utf-8") as f:
            hl7_raw = f.read().strip()
        # Normalize line endings to CR (HL7 standard)
        hl7_raw = hl7_raw.replace("\r\n", "\r").replace("\n", "\r")
    else:
        hl7_raw = generate_sample(args.generate)
        if not args.raw:
            print(f"Generated sample {args.generate} message")

    # Run the DTL test
    result = run_test_dtl(interop_url, username, password, args.dtl, hl7_raw)

    # Display results
    if args.raw:
        print(result)
        return

    filter_segs = None
    if args.show:
        filter_segs = [s.strip() for s in args.show.split(",")]

    show_message("SOURCE", hl7_raw, filter_segs)
    show_message("TARGET", result, filter_segs)

    if args.diff:
        show_diff(hl7_raw, result)


if __name__ == "__main__":
    main()
