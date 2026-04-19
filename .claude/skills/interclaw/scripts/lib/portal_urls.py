#!/usr/bin/env python3
"""Generate InterSystems Management Portal URLs for production components.

Given a server, namespace, and class names, outputs clickable URLs for:
  - Production configuration page
  - Rule editor
  - DTL editor
  - BPL editor
  - Lookup table settings
  - Message viewer
  - Event log

Usage:
  portal_urls.py --server myserver --namespace ELRIO --production ELRIOPKG.FoundationProduction
  portal_urls.py --server myserver --namespace ELRIO --classes "Pkg.Rule.MyRule,Pkg.DTL.MyTransform" --lookup "Facility_To_SII"
  portal_urls.py --server myserver --namespace ELRIO --all-from src/Demo/VaccineToASIIS/
"""

import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from iris_api import common_arg_parser, load_servers, build_base_url


def classify_from_source(source_text):
    """Determine component type by parsing the Extends clause from class source.

    This is the DETERMINISTIC classifier — it reads actual code, never guesses
    from names. Returns: dtl, rule, bpl, production, or None if not determinable.
    """
    if not source_text:
        return None

    # Match: Class Some.Name Extends (Super1, Super2) or Class Some.Name Extends Super
    m = re.search(r'(?i)^Class\s+\S+\s+Extends\s+(?:\(([^)]+)\)|(\S+))',
                  source_text, re.MULTILINE)
    if not m:
        return None

    supers_str = m.group(1) or m.group(2)
    supers = [s.strip().lower() for s in supers_str.split(",")]

    dtl_supers = {"ens.datatransformdtl", "ens.datatransform"}
    rule_supers = {"ens.rule.definition", "ens.rule.router.routingrule"}
    bpl_supers = {"ens.businessprocessbpl"}
    prod_supers = {"ens.production"}

    for s in supers:
        if s in dtl_supers:
            return "dtl"
        if s in rule_supers:
            return "rule"
        if s in bpl_supers:
            return "bpl"
        if s in prod_supers:
            return "production"

    return None


def classify_component(class_name, source_text=None):
    """Determine the component type from its class name and subpackage.

    If source_text is provided, tries deterministic classification first.
    Returns one of: production, rule, dtl, bpl, bp, bs, bo, msg, recordmap, unknown
    """
    # Deterministic: parse actual Extends clause if source is available
    if source_text:
        result = classify_from_source(source_text)
        if result:
            return result

    # Fallback: name-based heuristics
    parts = class_name.split(".")
    lower_parts = [p.lower() for p in parts]

    # Check subpackage naming convention
    if "rule" in lower_parts:
        return "rule"
    if "dtl" in lower_parts:
        return "dtl"
    if "bpl" in lower_parts:
        return "bpl"
    if "bp" in lower_parts:
        return "bp"
    if "bs" in lower_parts:
        return "bs"
    if "bo" in lower_parts:
        return "bo"
    if "msg" in lower_parts:
        return "msg"
    if "recordmap" in lower_parts:
        return "recordmap"

    # Check if it's the production class (ends with "Production")
    if parts[-1].lower() == "production":
        return "production"

    # Suffix heuristics
    last = parts[-1].lower() if parts else ""
    if last.endswith("transform") or last.endswith("passthrough"):
        return "dtl"
    if last.endswith("process") or last.endswith("dispatcher"):
        return "bpl"
    if last.endswith("routingrule"):
        return "rule"

    return "unknown"


ZEN_EDITORS = {
    "dtl":        ("EnsPortal.DTLEditor.zen?DT={name}.cls", "DTL Editor"),
    "rule":       ("EnsPortal.RuleEditor.zen?RULE={name}", "Rule Editor"),
    "bpl":        ("EnsPortal.BPLEditor.zen?BP={name}.cls", "BPL Editor"),
    "production": ("EnsPortal.ProductionConfig.zen?PRODUCTION={name}", "Production"),
    "schema":     ("EnsPortal.HL7.SchemaDocumentStructure.zen?MS={name}", "HL7 Schema"),
}

PROD_CONFIG_TYPES = {"bs", "bo", "bp", "msg", "recordmap"}


def get_zen_url(portal_base, namespace, class_name, comp_type=None):
    """Get the best Zen management portal URL for a class.

    Returns (url, label) or (None, None) if no meaningful page exists.
    """
    if comp_type is None:
        comp_type = classify_component(class_name)

    if comp_type in ZEN_EDITORS:
        pattern, label = ZEN_EDITORS[comp_type]
        return f"{portal_base}/{pattern.format(name=class_name)}", label

    if comp_type in PROD_CONFIG_TYPES:
        ns_upper = namespace.upper()
        return (f"{portal_base}/EnsPortal.ProductionConfig.zen"
                f"?$NAMESPACE={ns_upper}"), "Production Config"

    return None, None


def build_portal_base(server_config, namespace):
    """Build the Management Portal base URL.

    Pattern: {scheme}://{host}:{port}{pathPrefix}/csp/healthshare/{namespace_lower}/
    """
    ws = server_config["webServer"]
    scheme = ws.get("scheme", "http")
    host = ws["host"]
    port = ws.get("port", 80)
    path_prefix = ws.get("pathPrefix", "")
    ns_lower = namespace.lower()
    return f"{scheme}://{host}:{port}{path_prefix}/csp/healthshare/{ns_lower}"


def build_legacy_ui_url(server_config, namespace, zen_page_with_params):
    """Build a legacy-ui URL that loads a Zen page in the InterClaw wrapper.

    Pattern: {origin}{pathPrefix}/ui/interop/interclaw/legacy-ui/index.html#/csp/healthshare/{ns}/{zenPage}

    Example:
      http://myserver.example.com/irishealth/ui/interop/interclaw/legacy-ui/index.html#/csp/healthshare/interclaw/EnsPortal.DTLEditor.zen?DT=My.DTL.cls
    """
    ws = server_config["webServer"]
    scheme = ws.get("scheme", "http")
    host = ws["host"]
    port = ws.get("port", 80)
    path_prefix = ws.get("pathPrefix", "")
    ns_lower = namespace.lower()

    origin = f"{scheme}://{host}"
    if (scheme == "http" and port != 80) or (scheme == "https" and port != 443):
        origin += f":{port}"

    return (f"{origin}{path_prefix}/ui/interop/interclaw/legacy-ui/index.html"
            f"#/csp/healthshare/{ns_lower}/{zen_page_with_params}")


def get_legacy_ui_url(server_config, namespace, class_name, comp_type=None):
    """Get a legacy-ui wrapper URL for a class.

    Returns (url, label) or (None, None) if no editor exists for this type.
    """
    if comp_type is None:
        comp_type = classify_component(class_name)

    if comp_type in ZEN_EDITORS:
        pattern, label = ZEN_EDITORS[comp_type]
        zen_page = pattern.format(name=class_name)
        url = build_legacy_ui_url(server_config, namespace, zen_page)
        return url, label

    if comp_type in PROD_CONFIG_TYPES:
        ns_upper = namespace.upper()
        zen_page = f"EnsPortal.ProductionConfig.zen?$NAMESPACE={ns_upper}"
        url = build_legacy_ui_url(server_config, namespace, zen_page)
        return url, "Production Config"

    return None, None


def generate_urls(portal_base, namespace, production=None, classes=None, lookups=None):
    """Generate Management Portal URLs for the given components.

    Returns a list of (label, url, type) tuples.
    """
    urls = []
    ns_upper = namespace.upper()

    # Production config page
    if production:
        urls.append((
            f"Production: {production}",
            f"{portal_base}/EnsPortal.ProductionConfig.zen?PRODUCTION={production}",
            "production"
        ))

    # Classify and generate URLs for each class
    if classes:
        for cls in classes:
            cls = cls.strip()
            if not cls:
                continue

            comp_type = classify_component(cls)

            if comp_type == "production":
                # Skip if already added via the production parameter
                if cls == production:
                    continue
                urls.append((
                    f"Production: {cls}",
                    f"{portal_base}/EnsPortal.ProductionConfig.zen?PRODUCTION={cls}",
                    "production"
                ))

            elif comp_type == "rule":
                urls.append((
                    f"Rule Editor: {cls}",
                    f"{portal_base}/EnsPortal.RuleEditor.zen?RULE={cls}",
                    "rule"
                ))

            elif comp_type == "dtl":
                urls.append((
                    f"DTL Editor: {cls}",
                    f"{portal_base}/EnsPortal.DTLEditor.zen?DT={cls}.cls",
                    "dtl"
                ))

            elif comp_type == "bpl":
                urls.append((
                    f"BPL Editor: {cls}",
                    f"{portal_base}/EnsPortal.BPLEditor.zen?BP={cls}.cls",
                    "bpl"
                ))

            elif comp_type == "bp":
                # Code-based BP — link to class source in studio/portal
                urls.append((
                    f"Business Process: {cls}",
                    f"{portal_base}/EnsPortal.ProductionConfig.zen?PRODUCTION=&$NAMESPACE={ns_upper}",
                    "bp"
                ))

            elif comp_type in ("bs", "bo", "msg", "recordmap"):
                # No dedicated editor — link to production config
                pass

            elif comp_type == "unknown":
                pass

    # Lookup tables
    if lookups:
        for lt in lookups:
            lt = lt.strip()
            if not lt:
                continue
            urls.append((
                f"Lookup Table: {lt}",
                f"{portal_base}/EnsPortal.LookupSettings.zen?LookupTable={lt}.lut",
                "lookup"
            ))

    # Always include utility pages
    urls.append((
        "Message Viewer",
        f"{portal_base}/EnsPortal.MessageViewer.zen?$NAMESPACE={ns_upper}",
        "utility"
    ))
    urls.append((
        "Event Log",
        f"{portal_base}/EnsPortal.EventLog.zen?$NAMESPACE={ns_upper}",
        "utility"
    ))

    return urls


def scan_src_directory(src_path):
    """Scan a src/ directory tree for .cls files and extract class names.

    Class names are derived relative to the nearest ancestor 'src/' directory,
    so src/Demo/VaccineToASIIS/Production.cls becomes Demo.VaccineToASIIS.Production.

    Returns (classes, production) tuple.
    """
    classes = []
    production = None

    # Find the src/ root to compute full class names
    abs_src_path = os.path.abspath(src_path)
    src_root = _find_src_root(abs_src_path)

    for root, dirs, files in os.walk(abs_src_path):
        for f in files:
            if f.endswith(".cls"):
                # Derive class name relative to src/ root
                rel = os.path.relpath(os.path.join(root, f), src_root)
                # Convert path separators to dots, remove .cls
                cls_name = rel.replace(os.sep, ".").replace("/", ".")
                if cls_name.endswith(".cls"):
                    cls_name = cls_name[:-4]

                classes.append(cls_name)

                if cls_name.endswith(".Production") or cls_name.split(".")[-1] == "Production":
                    production = cls_name

    return classes, production


def _find_src_root(path):
    """Walk up from path to find the 'src' directory that is the package root.

    If path itself starts with a directory named 'src', returns that directory.
    Otherwise falls back to the given path.
    """
    # Normalize and split the absolute path into parts
    parts = os.path.normpath(path).split(os.sep)
    for i, part in enumerate(parts):
        if part.lower() == "src":
            return os.sep.join(parts[:i + 1])
    # Fallback: use the given path as-is
    return path


def main():
    parser = common_arg_parser("Generate Management Portal URLs for production components")

    parser.add_argument("--production", "-P",
                        help="Production class name")
    parser.add_argument("--classes",
                        help="Comma-separated list of class names")
    parser.add_argument("--lookup",
                        help="Comma-separated list of lookup table names")
    parser.add_argument("--all-from",
                        help="Scan a src/ directory for all .cls files")
    parser.add_argument("--format", choices=["text", "markdown", "json", "playwright"],
                        default="markdown",
                        help="Output format (default: markdown)")

    # Namespace is required, but password/config are not
    args = parser.parse_args()

    if not args.namespace:
        parser.error("--namespace is required")

    servers = load_servers(getattr(args, "config", None))
    server_name = args.server
    if server_name not in servers:
        print(f"ERROR: Server '{server_name}' not found", file=sys.stderr)
        sys.exit(1)

    server_config = servers[server_name]
    portal_base = build_portal_base(server_config, args.namespace)

    classes = []
    production = args.production
    lookups = []

    if args.classes:
        classes = args.classes.split(",")

    if args.lookup:
        lookups = args.lookup.split(",")

    if args.all_from:
        scanned_classes, scanned_prod = scan_src_directory(args.all_from)
        classes.extend(scanned_classes)
        if scanned_prod and not production:
            production = scanned_prod

    urls = generate_urls(portal_base, args.namespace, production, classes, lookups)

    if not urls:
        print("No components specified. Use --production, --classes, --lookup, or --all-from.",
              file=sys.stderr)
        sys.exit(1)

    if args.format == "json":
        output = [{"label": label, "url": url, "type": comp_type}
                  for label, url, comp_type in urls]
        print(json.dumps(output, indent=2))

    elif args.format == "markdown":
        print("## Management Portal Links\n")
        current_section = None
        sections = {
            "production": "Production",
            "rule": "Rules",
            "dtl": "Transforms",
            "bpl": "Business Processes (BPL)",
            "bp": "Business Processes",
            "lookup": "Lookup Tables",
            "utility": "Utilities"
        }
        for label, url, comp_type in urls:
            section = sections.get(comp_type, "Other")
            if section != current_section:
                print(f"### {section}\n")
                current_section = section
            print(f"- [{label}]({url})")
        print()

    elif args.format == "text":
        for label, url, comp_type in urls:
            print(f"{label}")
            print(f"  {url}")
            print()

    elif args.format == "playwright":
        print("// Playwright test URLs — generated by portal_urls.py")
        print("// Install: npm install @playwright/test")
        print()
        print("export const portalUrls = {")
        for label, url, comp_type in urls:
            # Create a camelCase key from the label
            key = re.sub(r'[^a-zA-Z0-9]', ' ', label).strip()
            key = key[0].lower() + re.sub(r'\s+(.)', lambda m: m.group(1).upper(), key[1:])
            key = re.sub(r'\s+', '', key)
            print(f'  {key}: "{url}",')
        print("};")
        print()
        print("// Example test:")
        print("// import { test, expect } from '@playwright/test';")
        print("// import { portalUrls } from './portal-urls';")
        print("//")
        print("// test('production is running', async ({ page }) => {")
        print("//   await page.goto(portalUrls.production);")
        print("//   await expect(page.locator('.productionState')).toContainText('Running');")
        print("// });")


if __name__ == "__main__":
    main()
