#!/usr/bin/env python3
"""Browse and extract POC sample exercises from the poc-examples catalog.

Usage:
  samples.py --list                          List all POCs and exercises
  samples.py --poc Sanford                   List exercises for a POC
  samples.py --poc Sanford --exercise 1      Extract exercise text for building
  samples.py --poc Sanford --exercise 1 --spec-only   Print spec path only
"""

import argparse
import os
import re
import sys
import textwrap

# ---------------------------------------------------------------------------
# Hardcoded POC catalog
# ---------------------------------------------------------------------------

CATALOG = [
    {
        "name": "Sanford",
        "dir": "2019-07-Sanford",
        "spec": "Sanford_SoW.md",
        "company": "Sanford Health",
        "year": 2019,
        "exercises": [
            {
                "num": 1,
                "heading": "Exercise #1: HL7 ADT Interface",
                "title": "HL7 ADT Interface",
                "summary": "One-to-many ADT routing with custom Z3R segments, lookup tables, MRN filtering, gender mapping",
                "messages": "ADT^A01",
                "features": ["DTL", "Routing Rule", "Lookup Table", "Custom Z-Segment", "BPL"],
            },
            {
                "num": 2,
                "heading": "Exercise #2: HL7 ORU Manipulation of OBX Segments",
                "title": "HL7 ORU Manipulation of OBX Segments",
                "summary": "ORU^R01 OBX segment formatting with header/footer insertion, numbering, NTE overflow",
                "messages": "ORU^R01",
                "features": ["DTL", "Routing Rule", "Foreach", "Segment Creation"],
            },
            {
                "num": 3,
                "heading": "Exercise #3: Database Connectivity and Data Enrichment",
                "title": "Database Connectivity and Data Enrichment",
                "summary": "ORM/SIU processing with SQL table storage, MRN/order lookup, SIU enrichment via database",
                "messages": "ORM^O01, SIU^S12",
                "features": ["BPL", "SQL", "DTL", "Routing Rule", "Database"],
            },
        ],
    },
    {
        "name": "ElRio",
        "dir": "2025-07-09-ElRio",
        "spec": "ElRio_POC.md",
        "company": "El Rio Health",
        "year": 2025,
        "exercises": [
            {
                "num": 1,
                "heading": "Build 1: Vaccine Administration to ASIIS",
                "title": "Vaccine Administration to ASIIS",
                "summary": "VXU TCP-to-HTTPS routing with HTTP Basic Auth, pediatric site lookup",
                "messages": "VXU^V04",
                "features": ["DTL", "Routing Rule", "Lookup Table", "HTTP Operation"],
            },
            {
                "num": 2,
                "heading": "Build 2: Imaging Orders to Rad Ltd",
                "title": "Imaging Orders to Rad Ltd",
                "summary": "ORM TCP-to-TCP filtering with conditional ORC field updates",
                "messages": "ORM^O01",
                "features": ["DTL", "Routing Rule", "Conditional Transform"],
            },
            {
                "num": 3,
                "heading": "Build 3: Image Order Results to Epic",
                "title": "Image Order Results to Epic",
                "summary": "SFTP-to-TCP ORU with Base64 embedded files, OBX replacements, ACK filtering",
                "messages": "ORU^R01, ACK",
                "features": ["DTL", "Routing Rule", "Base64", "File Operation"],
            },
        ],
    },
    {
        "name": "StClair",
        "dir": "2025-06-11-StClair",
        "spec": "StClair_POC.md",
        "company": "St. Clair Health",
        "year": 2025,
        "exercises": [
            {
                "num": 1,
                "heading": "Build 1: Batch Process",
                "title": "Batch Process",
                "summary": "HL7 batch processing via FTP with fixed-length delimited output, external Python program",
                "messages": "HL7 Batch",
                "features": ["Batch", "FTP", "Record Map", "Python"],
            },
            {
                "num": 2,
                "heading": "Build 2: Two Different Sources Sent into One Connection (One-To-Many)",
                "title": "Multi-Modality Imaging (One-To-Many)",
                "summary": "X-ray/CT/MRI/Ultrasound routing with OBX/NTE generation, Base64 PDF embedding",
                "messages": "ORU^R01",
                "features": ["DTL", "Routing Rule", "Lookup Table", "Base64", "PDF"],
            },
            {
                "num": 3,
                "heading": "Build 3: Main ADT Feed (Many-To-One)",
                "title": "Main ADT Feed (Many-To-One)",
                "summary": "ADT filtering with dual-path routing: TCP to RIS + file to billing with custom ZIN/ZPN segments",
                "messages": "ADT^A01, ADT^A08",
                "features": ["DTL", "Routing Rule", "Custom Z-Segment", "TCP", "File"],
            },
        ],
    },
    {
        "name": "SAS",
        "dir": "2025-08-11-SAS",
        "spec": "SAS_POC.md",
        "company": "SAS (HL7-to-FHIR)",
        "year": 2025,
        "exercises": [
            {
                "num": 1,
                "heading": "Build 1: HL7v2.5.1-to-FHIR",
                "title": "HL7v2.5.1-to-FHIR",
                "summary": "Standard ADT^A01 to FHIR via SDA intermediary, stores in native FHIR repository",
                "messages": "ADT^A01",
                "features": ["SDA", "FHIR", "DTL"],
            },
            {
                "num": 2,
                "heading": "Build 2: HL7v2.x-to-FHIR",
                "title": "HL7v2.x-to-FHIR",
                "summary": "Any HL7 v2.x (e.g., 2.3.1 RDE^O11) normalization to v2.5.1, then SDA-to-FHIR",
                "messages": "RDE^O11",
                "features": ["SDA", "FHIR", "Version Normalization"],
            },
            {
                "num": 3,
                "heading": "Build 3: CDA-to-FHIR",
                "title": "CDA-to-FHIR",
                "summary": "CDA document to FHIR via SDA intermediary, handles rich clinical content",
                "messages": "CDA",
                "features": ["SDA", "FHIR", "CDA"],
            },
        ],
    },
    {
        "name": "EirSystems",
        "dir": "2026-03-30-EirSystems",
        "spec": "EirSystemsPoCSow.md",
        "company": "EirSystems",
        "year": 2026,
        "exercises": [
            {
                "num": 1,
                "heading": "Evaluation 1.1: ADT^A01 to JSON",
                "title": "ADT^A01 to JSON Admit Payload",
                "summary": "TCP receives ADT^A01, routes by message type, transforms to JSON with MSH/PID/AL1 mapping",
                "messages": "ADT^A01",
                "features": ["DTL", "JSON Adapter", "Routing Rule", "TCP"],
            },
            {
                "num": 2,
                "heading": "Evaluation 1.2: RDS^O13 to JSON",
                "title": "RDS^O13 to JSON Order Payload",
                "summary": "TCP receives RDS^O13 medication order, routes by message type, transforms to JSON",
                "messages": "RDS^O13",
                "features": ["DTL", "JSON Adapter", "Routing Rule", "TCP"],
            },
        ],
    },
    {
        "name": "Sunquest",
        "dir": "2020-Sunquest",
        "spec": "Sunquest_SoW.md",
        "company": "Sunquest",
        "year": 2020,
        "exercises": [
            {
                "num": 1,
                "heading": "Exercise #1: Create HL7 APIs (2 hours)",
                "title": "HL7 Web Service APIs",
                "summary": "REST API for lab results with Record Mapper and DTL transformation to flat file",
                "messages": "HL7 via REST",
                "features": ["REST API", "Record Map", "DTL"],
            },
            {
                "num": 2,
                "heading": "Exercise #2: Create Generic REST APIs (1.5-2 hours)",
                "title": "Generic REST APIs",
                "summary": "REST service with TestConnection, GetPatientDemographics (GET), SendPatientDemographics (POST)",
                "messages": "JSON/REST",
                "features": ["REST API", "SQL", "JSON"],
            },
            {
                "num": 3,
                "heading": "Exercise #3: HL7 Data Enrichment with REST APIs (3-4 hours)",
                "title": "HL7 Data Enrichment with REST",
                "summary": "ORM enrichment via REST demographics call, transforms and outputs to TCP with TLS",
                "messages": "ORM^O01",
                "features": ["REST API", "DTL", "BPL", "TLS"],
            },
            {
                "num": 4,
                "heading": "Exercise #4: JSON Data Enrichment with REST APIs (2 hours)",
                "title": "JSON Data Enrichment with REST",
                "summary": "JSON payload enrichment reusing REST API from Exercise #2 for demographic mapping",
                "messages": "JSON",
                "features": ["REST API", "JSON Adapter", "BPL"],
            },
        ],
    },
]

# ---------------------------------------------------------------------------
# Heading patterns for exercise extraction from spec files
# ---------------------------------------------------------------------------

HEADING_PATTERNS = [
    r"^##\s+Exercise\s+#?\d",
    r"^##\s+Build\s+\d",
    r"^\*\*Evaluation\s+\d",
]


def find_project_root():
    """Walk up from script location to find project root (has poc-examples/)."""
    d = os.path.dirname(os.path.abspath(__file__))
    for _ in range(10):
        if os.path.isdir(os.path.join(d, "poc-examples")):
            return d
        d = os.path.dirname(d)
    return None


def spec_path(poc):
    """Return the absolute path to a POC's spec file."""
    root = find_project_root()
    if not root:
        return None
    return os.path.join(root, "poc-examples", poc["dir"], poc["spec"])


def find_poc(name):
    """Find a POC by name (case-insensitive, partial match)."""
    name_lower = name.lower()
    # Exact match first
    for poc in CATALOG:
        if poc["name"].lower() == name_lower:
            return poc
    # Partial match
    for poc in CATALOG:
        if name_lower in poc["name"].lower() or name_lower in poc["company"].lower():
            return poc
    return None


def extract_exercise_text(poc, exercise_num):
    """Extract an exercise section from a spec file.

    Returns (preamble, exercise_text) tuple.
    Preamble = everything before the first exercise heading.
    Exercise_text = from the matching heading to the next heading of same/higher level.
    """
    path = spec_path(poc)
    if not path or not os.path.isfile(path):
        return None, None

    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    lines = content.split("\n")

    # Find all exercise heading line numbers
    exercise_starts = []
    for i, line in enumerate(lines):
        for pattern in HEADING_PATTERNS:
            if re.match(pattern, line, re.IGNORECASE):
                exercise_starts.append(i)
                break

    if not exercise_starts:
        return content, None

    # Preamble = everything before the first exercise
    preamble = "\n".join(lines[: exercise_starts[0]]).strip()

    # Find the target exercise (1-indexed)
    if exercise_num < 1 or exercise_num > len(exercise_starts):
        return preamble, None

    start = exercise_starts[exercise_num - 1]
    if exercise_num < len(exercise_starts):
        end = exercise_starts[exercise_num]
    else:
        end = len(lines)

    exercise_text = "\n".join(lines[start:end]).strip()
    return preamble, exercise_text


# ---------------------------------------------------------------------------
# Output formatters
# ---------------------------------------------------------------------------

def print_catalog():
    """Print the full POC catalog."""
    print("POC Sample Catalog")
    print("=" * 70)
    print()

    for poc in CATALOG:
        path = spec_path(poc)
        exists = "OK" if path and os.path.isfile(path) else "MISSING"

        print(f"  {poc['name']:<14} {poc['company']:<25} [{exists}]")
        print(f"  {'':14} Spec: poc-examples/{poc['dir']}/{poc['spec']}")

        for ex in poc["exercises"]:
            features = ", ".join(ex["features"])
            print(f"  {'':14} {ex['num']}. {ex['title']}")
            print(f"  {'':14}    {ex['summary']}")
            print(f"  {'':14}    Messages: {ex['messages']}  |  Features: {features}")

        print()

    total = sum(len(p["exercises"]) for p in CATALOG)
    print(f"Total: {len(CATALOG)} POCs, {total} exercises")


def print_poc_exercises(poc):
    """Print exercises for a single POC."""
    path = spec_path(poc)
    exists = os.path.isfile(path) if path else False

    print(f"{poc['name']} — {poc['company']}")
    print(f"Spec: poc-examples/{poc['dir']}/{poc['spec']}", end="")
    print(f"  [{'OK' if exists else 'MISSING'}]")
    print("-" * 60)
    print()

    for ex in poc["exercises"]:
        features = ", ".join(ex["features"])
        print(f"  Exercise {ex['num']}: {ex['title']}")
        print(f"    {ex['summary']}")
        print(f"    Messages: {ex['messages']}")
        print(f"    Features: {features}")
        print()


def print_exercise_detail(poc, exercise_num):
    """Print the extracted exercise text for building."""
    exercises = poc["exercises"]
    match = None
    for ex in exercises:
        if ex["num"] == exercise_num:
            match = ex
            break

    if not match:
        print(f"ERROR: Exercise {exercise_num} not found in {poc['name']}.", file=sys.stderr)
        print(f"Available: {', '.join(str(e['num']) for e in exercises)}", file=sys.stderr)
        sys.exit(1)

    preamble, exercise_text = extract_exercise_text(poc, exercise_num)

    if exercise_text is None:
        print(f"ERROR: Could not extract exercise {exercise_num} from spec file.", file=sys.stderr)
        sys.exit(1)

    path = spec_path(poc)

    print(f"POC: {poc['name']} — {poc['company']}")
    print(f"Exercise: {match['num']}. {match['title']}")
    print(f"Spec: {path}")
    print(f"Package: {poc['name']}")
    print(f"Messages: {match['messages']}")
    print(f"Features: {', '.join(match['features'])}")
    print()
    print("=" * 60)
    print("PREAMBLE")
    print("=" * 60)
    print(preamble)
    print()
    print("=" * 60)
    print("EXERCISE")
    print("=" * 60)
    print(exercise_text)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Browse and extract POC sample exercises.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""\
            Examples:
              samples.py --list
              samples.py --poc Sanford
              samples.py --poc Sanford --exercise 1
              samples.py --poc ElRio --exercise 3 --spec-only
        """),
    )
    parser.add_argument("--list", action="store_true", help="List all POCs and exercises")
    parser.add_argument("--poc", type=str, help="POC name (case-insensitive, partial match)")
    parser.add_argument("--exercise", type=int, help="Exercise number to extract")
    parser.add_argument("--spec-only", action="store_true", help="Print spec file path only")
    parser.add_argument("--json", action="store_true", help="Output as JSON")

    args = parser.parse_args()

    # Default to --list if no args
    if not args.list and not args.poc:
        args.list = True

    if args.list:
        if args.json:
            import json
            out = []
            for poc in CATALOG:
                out.append({
                    "name": poc["name"],
                    "company": poc["company"],
                    "spec": f"poc-examples/{poc['dir']}/{poc['spec']}",
                    "exercises": [
                        {"num": e["num"], "title": e["title"], "summary": e["summary"],
                         "messages": e["messages"], "features": e["features"]}
                        for e in poc["exercises"]
                    ],
                })
            print(json.dumps(out, indent=2))
        else:
            print_catalog()
        return

    # Find the POC
    poc = find_poc(args.poc)
    if not poc:
        print(f"ERROR: POC '{args.poc}' not found.", file=sys.stderr)
        print(f"Available: {', '.join(p['name'] for p in CATALOG)}", file=sys.stderr)
        sys.exit(1)

    if args.spec_only:
        path = spec_path(poc)
        if path:
            print(path)
        return

    if args.exercise:
        print_exercise_detail(poc, args.exercise)
    else:
        print_poc_exercises(poc)


if __name__ == "__main__":
    main()
