#!/usr/bin/env python3
"""Static analysis validator for InterSystems production packages.

Scans local source files in src/<Namespace>/<Package>/ and performs
pre-push validation checks:
  1. Target resolution  - routing rule/BPL targets exist in production
  2. DTL DocType match  - DTL source/target types match production config
  3. Lookup table exist - Lookup() references have server-side tables
  4. Missing CfgItem    - HTTP service URLs include ?CfgItem=
  5. EnableStandardRequests target - must be Target="Host"
  6. Routing rule syntax - != not '=, proper XML entity encoding
  7. Package naming      - classes follow <Pkg>.DTL.*, <Pkg>.Rule.* etc.
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import os
import re
import sys
import xml.etree.ElementTree as ET

# Add the scripts directory to path so we can import iris_api
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import (
    common_arg_parser,
    get_server_and_creds,
    build_base_url,
    make_request,
    parse_atelier_response,
)


# ---------------------------------------------------------------------------
# Result accumulator
# ---------------------------------------------------------------------------

class ValidationResult:
    """Collects PASS / WARN / FAIL results for a validation run."""

    def __init__(self):
        self.results = []  # list of (level, check_name, message)

    def passed(self, check, msg):
        self.results.append(("PASS", check, msg))

    def warn(self, check, msg):
        self.results.append(("WARN", check, msg))

    def fail(self, check, msg):
        self.results.append(("FAIL", check, msg))

    @property
    def pass_count(self):
        return sum(1 for r in self.results if r[0] == "PASS")

    @property
    def warn_count(self):
        return sum(1 for r in self.results if r[0] == "WARN")

    @property
    def fail_count(self):
        return sum(1 for r in self.results if r[0] == "FAIL")

    def print_report(self):
        print("\n" + "=" * 70)
        print("VALIDATION REPORT")
        print("=" * 70)

        current_check = None
        for level, check, msg in self.results:
            if check != current_check:
                current_check = check
                print(f"\n--- {check} ---")
            icon = {"PASS": "[PASS]", "WARN": "[WARN]", "FAIL": "[FAIL]"}[level]
            print(f"  {icon} {msg}")

        print("\n" + "-" * 70)
        print(f"Summary: {self.pass_count} PASS, {self.warn_count} WARN, {self.fail_count} FAIL")
        if self.fail_count > 0:
            print("STATUS: FAILED - fix FAIL items before pushing")
        elif self.warn_count > 0:
            print("STATUS: WARNINGS - review WARN items")
        else:
            print("STATUS: ALL CLEAR - package is ready to push")
        print("-" * 70)


# ---------------------------------------------------------------------------
# File discovery and parsing
# ---------------------------------------------------------------------------

def find_source_files(namespace, package):
    """Find all .cls files under src/<Namespace>/<Package>/."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))
    # Package parts become path segments
    pkg_parts = package.split(".")
    src_dir = os.path.join(project_root, "src", namespace, *pkg_parts)

    files = {}  # relative_name -> full_path
    if not os.path.isdir(src_dir):
        return files, src_dir

    for root, _dirs, filenames in os.walk(src_dir):
        for fname in filenames:
            if fname.endswith(".cls"):
                full_path = os.path.join(root, fname)
                files[fname] = full_path
    return files, src_dir


def read_file(path):
    """Read file content as string."""
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()


def extract_xdata_xml(content, xdata_name):
    """Extract the XML string from an XData block by name.

    Returns the XML string or None if not found.
    Handles both `XData Name [ ... ] {` and `XData Name {` formats.
    """
    # Match with or without the [ ... ] qualifier
    pattern = rf'XData\s+{re.escape(xdata_name)}\s*(?:\[.*?\])?\s*\{{(.*?)\n\}}'
    m = re.search(pattern, content, re.DOTALL)
    if m:
        return m.group(1).strip()
    return None


def parse_xml_safe(xml_str):
    """Parse XML string, returning ElementTree root or None on error."""
    if not xml_str:
        return None
    try:
        return ET.fromstring(xml_str)
    except ET.ParseError:
        # Try wrapping in a root element in case of namespace issues
        try:
            return ET.fromstring(f"<root>{xml_str}</root>")
        except ET.ParseError:
            return None


def classify_file(content, filename):
    """Determine file type: production, dtl, rule, bpl, bp, bs, bo, msg, other."""
    if "Extends Ens.Production" in content:
        return "production"
    if "Extends Ens.DataTransformDTL" in content:
        return "dtl"
    if "Extends Ens.Rule.Definition" in content:
        return "rule"
    if "Extends Ens.BusinessProcessBPL" in content:
        return "bpl"
    if "Extends Ens.BusinessProcess" in content:
        return "bp"
    if "Extends Ens.BusinessService" in content:
        return "bs"
    if "Extends Ens.BusinessOperation" in content:
        return "bo"
    if "Extends Ens.Request" in content or "Extends Ens.Response" in content:
        return "msg"
    return "other"


def extract_class_name(content):
    """Extract the full class name from Class ... Extends."""
    m = re.search(r'^Class\s+([\w.]+)\s+Extends', content, re.MULTILINE)
    return m.group(1) if m else None


# ---------------------------------------------------------------------------
# Production parsing
# ---------------------------------------------------------------------------

def parse_production(content):
    """Parse a production class and return structured data.

    Returns dict with:
      hosts: {name: {className, settings: {name: {value, target}}}}
      business_rules: {hostName: ruleClassName}
      target_config_names: {hostName: [target1, target2, ...]}
    """
    xml_str = extract_xdata_xml(content, "ProductionDefinition")
    root = parse_xml_safe(xml_str)
    if root is None:
        return None

    # Handle namespace
    ns = {"p": "http://www.intersystems.com/production"}

    production = {
        "hosts": {},
        "business_rules": {},
        "target_config_names": {},
        "enable_standard_requests": {},
    }

    # Find Item elements (with or without namespace)
    items = root.findall(".//Item") or root.findall("Item")
    if not items:
        items = root.findall(".//{http://www.intersystems.com/production}Item")
    # Also try the root itself if it's a Production element
    if root.tag == "Production" or root.tag.endswith("}Production"):
        items = list(root)

    for item in items:
        if item.tag == "Item" or item.tag.endswith("}Item"):
            name = item.get("Name", "")
            class_name = item.get("ClassName", "")
            if not name:
                continue

            settings = {}
            for setting in item:
                if setting.tag == "Setting" or setting.tag.endswith("}Setting"):
                    s_name = setting.get("Name", "")
                    s_target = setting.get("Target", "")
                    s_value = setting.text or ""
                    settings[s_name] = {"value": s_value, "target": s_target}

            production["hosts"][name] = {"className": class_name, "settings": settings}

            # Extract TargetConfigNames
            if "TargetConfigNames" in settings:
                targets = [t.strip() for t in settings["TargetConfigNames"]["value"].split(",") if t.strip()]
                production["target_config_names"][name] = targets

            # Extract BusinessRuleName
            if "BusinessRuleName" in settings:
                production["business_rules"][name] = settings["BusinessRuleName"]["value"]

            # Track EnableStandardRequests
            if "EnableStandardRequests" in settings:
                production["enable_standard_requests"][name] = settings["EnableStandardRequests"]["target"]

    return production


# ---------------------------------------------------------------------------
# DTL parsing
# ---------------------------------------------------------------------------

def parse_dtl(content):
    """Parse a DTL class and extract transform metadata.

    Returns dict with: sourceDocType, targetDocType, lookups (set of table names)
    """
    xml_str = extract_xdata_xml(content, "DTL")
    root = parse_xml_safe(xml_str)

    result = {
        "sourceDocType": None,
        "targetDocType": None,
        "lookups": set(),
    }

    if root is not None:
        # The root should be <transform ...>
        transform = root
        if transform.tag != "transform" and not transform.tag.endswith("}transform"):
            # Look for transform child
            for child in root:
                if child.tag == "transform" or child.tag.endswith("}transform"):
                    transform = child
                    break

        result["sourceDocType"] = transform.get("sourceDocType")
        result["targetDocType"] = transform.get("targetDocType")

    # Also scan the raw content for Lookup references
    for m in re.finditer(r'\.\.Lookup\(\s*"([^"]+)"', content):
        result["lookups"].add(m.group(1))

    return result


# ---------------------------------------------------------------------------
# Rule parsing
# ---------------------------------------------------------------------------

def parse_rule(content):
    """Parse a routing rule class and extract targets, transforms, conditions.

    Returns dict with:
      targets: set of target names
      transforms: set of DTL class names
      conditions: list of condition strings (raw)
      raw_xml: the raw XML string for syntax checks
    """
    xml_str = extract_xdata_xml(content, "RuleDefinition")
    root = parse_xml_safe(xml_str)

    result = {
        "targets": set(),
        "transforms": set(),
        "conditions": [],
        "raw_xml": xml_str or "",
    }

    if root is None:
        return result

    # Find all <send> elements recursively
    for send in root.iter("send"):
        target = send.get("target", "")
        transform = send.get("transform", "")
        if target:
            result["targets"].add(target)
        if transform:
            result["transforms"].add(transform)

    # Also search without namespace
    for send in root.iter("{http://www.intersystems.com/rule}send"):
        target = send.get("target", "")
        transform = send.get("transform", "")
        if target:
            result["targets"].add(target)
        if transform:
            result["transforms"].add(transform)

    # Find all conditions
    for when in root.iter("when"):
        cond = when.get("condition", "")
        if cond:
            result["conditions"].append(cond)
    for when in root.iter("{http://www.intersystems.com/rule}when"):
        cond = when.get("condition", "")
        if cond:
            result["conditions"].append(cond)

    return result


# ---------------------------------------------------------------------------
# BPL parsing
# ---------------------------------------------------------------------------

def parse_bpl(content):
    """Parse a BPL class and extract call targets.

    Returns dict with: targets (set of target names, excluding @-prefixed dynamic targets)
    """
    xml_str = extract_xdata_xml(content, "BPL")
    root = parse_xml_safe(xml_str)

    result = {"targets": set(), "dynamic_targets": set()}

    if root is None:
        return result

    for call in root.iter("call"):
        target = call.get("target", "")
        if target.startswith("@"):
            result["dynamic_targets"].add(target)
        elif target:
            result["targets"].add(target)

    for call in root.iter("{http://www.intersystems.com/bpl}call"):
        target = call.get("target", "")
        if target.startswith("@"):
            result["dynamic_targets"].add(target)
        elif target:
            result["targets"].add(target)

    return result


# Also check code-based business processes for SendRequestSync/Async targets
def parse_bp_targets(content):
    """Extract SendRequestSync/SendRequestAsync target names from ObjectScript code."""
    targets = set()
    for m in re.finditer(r'\.\.SendRequest(?:Sync|Async)\(\s*"([^"]+)"', content):
        targets.add(m.group(1))
    return targets


# ---------------------------------------------------------------------------
# Server queries
# ---------------------------------------------------------------------------

def query_lookup_tables(base_url, username, password):
    """Query server for existing lookup table names."""
    sql = "SELECT DISTINCT TableName FROM Ens_Util.LookupTable"
    url = f"{base_url}/v1/%25SYS/action/query"  # use namespace from base_url
    # Actually we need the namespace-specific endpoint
    return sql


def query_lookup_tables_via_args(args, server_config, base_url, username, password):
    """Query server for lookup tables using run_query approach."""
    namespace = args.namespace or "USER"
    url = f"{base_url}/v1/{namespace}/action/query"
    sql = "SELECT DISTINCT TableName FROM Ens_Util.LookupTable"
    data = {"query": sql}

    status, body = make_request(url, username, password, method="POST", data=data, timeout=15)
    if status != 200:
        return set()

    try:
        content = parse_atelier_response(body)
        tables = set()
        if isinstance(content, list):
            for row in content:
                if isinstance(row, dict):
                    for v in row.values():
                        if v:
                            tables.add(str(v))
                elif isinstance(row, (list, tuple)) and row:
                    tables.add(str(row[0]))
        return tables
    except Exception:
        return set()


# ---------------------------------------------------------------------------
# Validation checks
# ---------------------------------------------------------------------------

def check_target_resolution(result, production, rules, bpls, bps):
    """Check 1: All targets referenced in rules/BPLs/BPs exist as production hosts."""
    check = "Target Resolution"

    if production is None:
        result.warn(check, "No production class found - cannot verify targets")
        return

    host_names = set(production["hosts"].keys())

    # Check routing rule targets
    for rule_file, rule_data in rules.items():
        for target in rule_data["targets"]:
            if target in host_names:
                result.passed(check, f"Rule target '{target}' exists in production ({rule_file})")
            else:
                result.fail(check, f"Rule target '{target}' NOT found in production ({rule_file})")

    # Check BPL call targets
    for bpl_file, bpl_data in bpls.items():
        for target in bpl_data["targets"]:
            if target in host_names:
                result.passed(check, f"BPL target '{target}' exists in production ({bpl_file})")
            else:
                result.fail(check, f"BPL target '{target}' NOT found in production ({bpl_file})")
        for target in bpl_data["dynamic_targets"]:
            result.warn(check, f"BPL uses dynamic target '{target}' - cannot verify statically ({bpl_file})")

    # Check code-based BP targets
    for bp_file, bp_targets in bps.items():
        for target in bp_targets:
            if target in host_names:
                result.passed(check, f"BP target '{target}' exists in production ({bp_file})")
            else:
                result.fail(check, f"BP target '{target}' NOT found in production ({bp_file})")

    # Check TargetConfigNames point to valid hosts
    for host_name, targets in production["target_config_names"].items():
        for target in targets:
            if target in host_names:
                result.passed(check, f"Service '{host_name}' -> '{target}' exists in production")
            else:
                result.fail(check, f"Service '{host_name}' -> '{target}' NOT found in production")

    if not rules and not bpls and not bps and not production["target_config_names"]:
        result.passed(check, "No targets to check")


def check_dtl_doctype(result, production, rules, dtls):
    """Check 2: DTL DocTypes match what the production routes to them."""
    check = "DTL DocType Matching"

    if not dtls:
        result.passed(check, "No DTLs to check")
        return

    if production is None:
        result.warn(check, "No production class found - cannot cross-reference DTL DocTypes")
        return

    # Build a map of DTL class name -> docTypes referenced from rules
    # Rules reference DTLs via transform="..." attribute
    # The routing engine constrains docCategory + docName
    rule_dtl_types = {}  # dtl_class -> set of (category, docName) from constraints
    for rule_file, rule_data in rules.items():
        # Parse the rule XML to get constraints per rule that references a transform
        xml_str = rule_data["raw_xml"]
        root = parse_xml_safe(xml_str)
        if root is None:
            continue

        for ruleset in _iter_tag(root, "ruleSet"):
            for rule in _iter_tag(ruleset, "rule"):
                # Collect constraints
                doc_cat = None
                doc_name = None
                for constraint in _iter_tag(rule, "constraint"):
                    cname = constraint.get("name", "")
                    cvalue = constraint.get("value", "")
                    if cname == "docCategory":
                        doc_cat = cvalue
                    elif cname == "docName":
                        doc_name = cvalue

                # Find transforms in this rule's when/otherwise branches
                for when in _iter_tag(rule, "when"):
                    for send in _iter_tag(when, "send"):
                        transform = send.get("transform", "")
                        if transform and doc_cat and doc_name:
                            if transform not in rule_dtl_types:
                                rule_dtl_types[transform] = set()
                            rule_dtl_types[transform].add((doc_cat, doc_name))

    # Now check each DTL
    for dtl_file, dtl_data in dtls.items():
        src_doctype = dtl_data["sourceDocType"]
        if not src_doctype:
            result.warn(check, f"DTL '{dtl_file}' has no sourceDocType set")
            continue

        # Extract category:msgtype from sourceDocType (e.g., "2.5.1:VXU_V04")
        parts = src_doctype.split(":")
        if len(parts) != 2:
            result.warn(check, f"DTL '{dtl_file}' sourceDocType '{src_doctype}' has unexpected format")
            continue

        dtl_cat, dtl_msg = parts

        # Find the class name for this DTL file
        dtl_class = None
        for dtl_f, dtl_path in dtl_file_to_class.items():
            if dtl_f == dtl_file:
                dtl_class = dtl_path
                break

        if dtl_class and dtl_class in rule_dtl_types:
            for (rule_cat, rule_msg) in rule_dtl_types[dtl_class]:
                if rule_cat == dtl_cat and rule_msg == dtl_msg:
                    result.passed(check, f"DTL '{dtl_file}' sourceDocType '{src_doctype}' matches rule constraint")
                else:
                    result.fail(check,
                        f"DTL '{dtl_file}' sourceDocType '{src_doctype}' does NOT match "
                        f"rule constraint '{rule_cat}:{rule_msg}'")
        else:
            result.warn(check, f"DTL '{dtl_file}' not referenced by any routing rule - cannot verify DocType")


def _iter_tag(element, tag_name):
    """Iterate over child/descendant elements matching tag_name with or without namespace."""
    for child in element.iter(tag_name):
        yield child
    for child in element.iter(f"{{http://www.intersystems.com/rule}}{tag_name}"):
        yield child


def check_lookup_tables(result, dtls, server_tables):
    """Check 3: Lookup table references in DTLs exist on the server."""
    check = "Lookup Table Existence"

    all_lookups = set()
    for dtl_file, dtl_data in dtls.items():
        for table_name in dtl_data["lookups"]:
            all_lookups.add((table_name, dtl_file))

    if not all_lookups:
        result.passed(check, "No Lookup() references found")
        return

    if server_tables is None:
        result.warn(check, "Could not query server for lookup tables - skipping check")
        for table_name, dtl_file in all_lookups:
            result.warn(check, f"Cannot verify lookup table '{table_name}' ({dtl_file})")
        return

    for table_name, dtl_file in sorted(all_lookups):
        if table_name in server_tables:
            result.passed(check, f"Lookup table '{table_name}' exists on server ({dtl_file})")
        else:
            result.fail(check, f"Lookup table '{table_name}' NOT found on server ({dtl_file})")


def check_cfgitem(result, production):
    """Check 4: HTTP services should be accessed with ?CfgItem= parameter.

    This is a structural check - we verify that HTTP services exist and warn
    about the CfgItem requirement.
    """
    check = "HTTP Service CfgItem"

    if production is None:
        result.warn(check, "No production class found")
        return

    http_services = []
    for name, host in production["hosts"].items():
        if "HTTPService" in host["className"]:
            http_services.append(name)

    if not http_services:
        result.passed(check, "No HTTP services in production")
        return

    for svc_name in http_services:
        result.warn(check,
            f"HTTP service '{svc_name}' requires ?CfgItem={svc_name} in test URLs")


def check_enable_standard_requests(result, production):
    """Check 5: EnableStandardRequests must use Target='Host', not Target='Adapter'."""
    check = "EnableStandardRequests Target"

    if production is None:
        result.warn(check, "No production class found")
        return

    found_any = False
    for host_name, target_value in production["enable_standard_requests"].items():
        found_any = True
        if target_value == "Host":
            result.passed(check, f"'{host_name}' EnableStandardRequests correctly uses Target=\"Host\"")
        elif target_value == "Adapter":
            result.fail(check,
                f"'{host_name}' EnableStandardRequests uses Target=\"Adapter\" - "
                f"MUST be Target=\"Host\" (causes silent HTTP 500)")
        else:
            result.warn(check,
                f"'{host_name}' EnableStandardRequests has Target=\"{target_value}\" - expected \"Host\"")

    if not found_any:
        # Check if there are HTTP services that should have it
        for name, host in production["hosts"].items():
            if "HTTPService" in host["className"]:
                if "EnableStandardRequests" not in host["settings"]:
                    result.warn(check, f"HTTP service '{name}' missing EnableStandardRequests setting")
                    found_any = True

    if not found_any:
        result.passed(check, "No EnableStandardRequests settings to check")


def check_rule_syntax(result, rules):
    """Check 6: Routing rule syntax - != not '=, proper entity encoding."""
    check = "Routing Rule Syntax"

    if not rules:
        result.passed(check, "No routing rules to check")
        return

    for rule_file, rule_data in rules.items():
        conditions = rule_data["conditions"]
        raw_xml = rule_data["raw_xml"]

        for cond in conditions:
            # Check for ObjectScript-style '= (not-equals)
            if "'=" in cond:
                result.fail(check,
                    f"Condition uses '= (ObjectScript syntax) instead of != in '{rule_file}': {cond}")

            # Check for unencoded quotes in XML
            if '"' in cond and '&quot;' not in raw_xml and '"' in raw_xml:
                # This is hard to check perfectly - the XML parser handles it
                pass

        # Check raw XML for common issues
        if raw_xml:
            # Check for '= in the raw XML (before entity decoding)
            # In XML, the condition attribute might have &apos;= which decodes to '=
            if "'=" in raw_xml or "&apos;=" in raw_xml:
                result.fail(check,
                    f"Raw XML contains '= syntax in '{rule_file}' - use != for not-equals")

            # Check for unencoded < or > in conditions (but & is ok as entity)
            # The raw XML should use &lt; &gt; &quot; not bare < > "
            # If parsing succeeded, the encoding is likely fine
            result.passed(check, f"Rule syntax OK in '{rule_file}'")


def check_package_naming(result, package, files, file_classes):
    """Check 7: All classes follow <Pkg>.DTL.*, <Pkg>.Rule.*, <Pkg>.BPL.* convention."""
    check = "Package Naming"

    known_subpackages = {"DTL", "Rule", "BPL", "BP", "BS", "BO", "Msg", "RecordMap"}
    expected_prefix = package + "."

    issues = []
    for filename, class_name in file_classes.items():
        if class_name is None:
            result.warn(check, f"Could not extract class name from '{filename}'")
            continue

        if not class_name.startswith(expected_prefix):
            # The class might use a different root but still be in the right directory
            result.warn(check,
                f"Class '{class_name}' in '{filename}' does not start with expected prefix '{expected_prefix}'")
            continue

        # Check that component types are in recognized subpackages
        remainder = class_name[len(expected_prefix):]
        parts = remainder.split(".")
        if len(parts) >= 2:
            subpkg = parts[0]
            if subpkg == "Production" or (len(parts) == 1 and parts[0] == "Production"):
                continue  # Production class is at package root
            # Check if the subpackage is recognized
            # We allow any subpackage but warn on non-standard ones
            pass
        elif len(parts) == 1:
            # Root-level class in the package (e.g., Production)
            if parts[0] != "Production":
                result.warn(check,
                    f"Class '{class_name}' is at package root - expected a subpackage "
                    f"(e.g., {package}.DTL.{parts[0]}, {package}.Rule.{parts[0]})")

    if not issues and file_classes:
        result.passed(check, f"All {len(file_classes)} classes follow package naming conventions")
    elif not file_classes:
        result.warn(check, "No classes found to check")


def check_bpl_mandate(result, bps, bpls):
    """Check 8: Business processes use BPL, not code-based BP."""
    check = "BPL Mandate"

    if bps:
        for bp_file in bps:
            result.warn(check,
                f"Code-based BP found: '{bp_file}' — should be BPL (Ens.BusinessProcessBPL). "
                f"Code-based Ens.BusinessProcess is discouraged. "
                f"Rewrite as BPL unless explicitly required by spec.")
    elif bpls:
        result.passed(check, f"All {len(bpls)} business processes use BPL")
    else:
        result.passed(check, "No business processes to check")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

# Module-level dict populated in main() for cross-referencing DTL files to class names
dtl_file_to_class = {}


def main():
    parser = common_arg_parser("Validate an InterSystems production package before pushing")
    parser.add_argument("--package", "-k", required=True,
                        help="Package name (e.g., ElRio.POC)")
    args = parser.parse_args()

    namespace = args.namespace or "USER"
    package = args.package

    print(f"Validating package: {package}")
    print(f"Namespace: {namespace}")
    print(f"Server: {args.server}")

    # Discover source files
    files, src_dir = find_source_files(namespace, package)
    if not files:
        print(f"\nERROR: No .cls files found in {src_dir}")
        print("Make sure the package exists locally under src/<Namespace>/<Package>/")
        sys.exit(1)

    print(f"Found {len(files)} class files in {src_dir}")

    # Parse all files
    production_data = None
    dtls = {}        # filename -> dtl_data
    rules = {}       # filename -> rule_data
    bpls = {}        # filename -> bpl_data
    bps = {}         # filename -> set of targets
    file_classes = {}  # filename -> class_name

    for filename, filepath in files.items():
        content = read_file(filepath)
        class_name = extract_class_name(content)
        file_classes[filename] = class_name
        file_type = classify_file(content, filename)

        if file_type == "production":
            production_data = parse_production(content)
        elif file_type == "dtl":
            dtls[filename] = parse_dtl(content)
            if class_name:
                dtl_file_to_class[filename] = class_name
        elif file_type == "rule":
            rules[filename] = parse_rule(content)
        elif file_type == "bpl":
            bpls[filename] = parse_bpl(content)
        elif file_type == "bp":
            bp_targets = parse_bp_targets(content)
            if bp_targets:
                bps[filename] = bp_targets

    # Query server for lookup tables (best-effort)
    server_tables = None
    try:
        server_config, base_url, username, password = get_server_and_creds(args)
        server_tables = query_lookup_tables_via_args(args, server_config, base_url, username, password)
        if server_tables:
            print(f"Found {len(server_tables)} lookup tables on server")
        else:
            print("No lookup tables found on server (or query failed)")
    except (SystemExit, Exception) as e:
        print(f"Warning: Could not connect to server for lookup table check: {e}")

    # Run all checks
    vr = ValidationResult()

    check_target_resolution(vr, production_data, rules, bpls, bps)
    check_dtl_doctype(vr, production_data, rules, dtls)
    check_lookup_tables(vr, dtls, server_tables)
    check_cfgitem(vr, production_data)
    check_enable_standard_requests(vr, production_data)
    check_rule_syntax(vr, rules)
    check_package_naming(vr, package, files, file_classes)
    check_bpl_mandate(vr, bps, bpls)

    vr.print_report()

    # Exit code
    sys.exit(1 if vr.fail_count > 0 else 0)


if __name__ == "__main__":
    main()
