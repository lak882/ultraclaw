#!/usr/bin/env python3
"""Validate and report on the Management Portal URL catalog.

The catalog lives in `config/portal-urls.json` and is hand-curated. This script
loads it, checks structural invariants, reports entry counts per category,
and optionally probes every URL against a live server to flag broken links.

Usage:
  catalog_portal_urls.py                         # validate + summary
  catalog_portal_urls.py --list                  # list every entry, one per line
  catalog_portal_urls.py --probe --server interclaw-test --namespace INTERCLAW
  catalog_portal_urls.py --json                  # emit machine-readable report on stdout

Exit codes:
  0 = valid (and all probes passed when --probe is set)
  1 = validation errors, or probe failures when --probe is set
"""

import argparse
import base64
import json
import os
import sys
import urllib.error
import urllib.request


REQUIRED_FIELDS = {"slug", "title", "url", "category"}
OPTIONAL_FIELDS = {"aliases", "keywords", "description", "requires"}


def project_root():
    here = os.path.dirname(os.path.abspath(__file__))
    return os.path.abspath(os.path.join(here, "..", "..", "..", "..", ".."))


def load_catalog(path):
    with open(path) as f:
        return json.load(f)


def load_server(name, config_path):
    with open(config_path) as f:
        data = json.load(f)
    servers = data.get("intersystems.servers", {})
    if name not in servers:
        raise SystemExit(f"server '{name}' not found in {config_path}")
    return servers[name]


def validate(catalog):
    errors = []
    entries = catalog.get("entries", [])
    seen_slugs = set()
    for i, entry in enumerate(entries):
        prefix = f"entries[{i}]"
        missing = REQUIRED_FIELDS - entry.keys()
        if missing:
            errors.append(f"{prefix}: missing required fields {sorted(missing)}")
            continue
        if entry["slug"] in seen_slugs:
            errors.append(f"{prefix}: duplicate slug '{entry['slug']}'")
        seen_slugs.add(entry["slug"])
        unknown = (entry.keys() - REQUIRED_FIELDS) - OPTIONAL_FIELDS
        if unknown:
            errors.append(f"{prefix}: unknown fields {sorted(unknown)}")
        tpl = entry.get("url", "")
        if "{name}" in tpl and "name" not in (entry.get("requires") or []):
            errors.append(f"{prefix} slug={entry['slug']}: template uses {{name}} but does not declare requires:['name']")
    return errors


def expand(tpl, server, namespace, name=""):
    origin = f"{server['webServer']['scheme']}://{server['webServer']['host']}"
    port = server["webServer"].get("port", 80)
    if port not in (80, 443):
        origin += f":{port}"
    prefix = server["webServer"].get("pathPrefix", "") or ""
    return (tpl
        .replace("{origin}", origin)
        .replace("{pathPrefix}", prefix)
        .replace("{namespace}", namespace.upper())
        .replace("{namespaceLower}", namespace.lower())
        .replace("{name}", name))


def probe(url, auth_header):
    req = urllib.request.Request(url, method="HEAD", headers={"Authorization": auth_header})
    try:
        with urllib.request.urlopen(req, timeout=8) as r:
            return r.status
    except urllib.error.HTTPError as e:
        # Many SMP pages return 405 on HEAD but render fine on GET — retry.
        if e.code == 405:
            try:
                req2 = urllib.request.Request(url, headers={"Authorization": auth_header})
                with urllib.request.urlopen(req2, timeout=8) as r2:
                    return r2.status
            except Exception as e2:
                return f"ERR({e2})"
        return e.code
    except Exception as e:
        return f"ERR({e})"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--catalog", default=None, help="Path to portal-urls.json (default: config/portal-urls.json)")
    ap.add_argument("--config", default=None, help="Path to servers.json (default: config/servers.json)")
    ap.add_argument("--server", help="Named server from servers.json; required for --probe")
    ap.add_argument("--namespace", default="INTERCLAW", help="Namespace for probing (default: INTERCLAW)")
    ap.add_argument("--list", action="store_true", help="List every entry (slug, category, title)")
    ap.add_argument("--probe", action="store_true", help="HTTP-probe every URL against --server")
    ap.add_argument("--json", action="store_true", help="Emit a machine-readable JSON report on stdout")
    args = ap.parse_args()

    root = project_root()
    catalog_path = args.catalog or os.path.join(root, "config", "portal-urls.json")
    servers_path = args.config or os.path.join(root, "config", "servers.json")

    catalog = load_catalog(catalog_path)
    entries = catalog.get("entries", [])
    errors = validate(catalog)
    by_category = {}
    for e in entries:
        by_category.setdefault(e.get("category", "uncategorized"), []).append(e)

    probes = []
    if args.probe:
        if not args.server:
            raise SystemExit("--probe requires --server")
        server = load_server(args.server, servers_path)
        user = server.get("username", "")
        pw = server.get("password", "")
        auth = "Basic " + base64.b64encode(f"{user}:{pw}".encode()).decode()
        for e in entries:
            if "{name}" in e["url"]:
                # Skip — these need a target, not a smoke-test
                probes.append({"slug": e["slug"], "status": "SKIPPED(requires name)"})
                continue
            url = expand(e["url"], server, args.namespace)
            probes.append({"slug": e["slug"], "url": url, "status": probe(url, auth)})

    if args.json:
        json.dump({
            "catalog": catalog_path,
            "total": len(entries),
            "by_category": {k: len(v) for k, v in sorted(by_category.items())},
            "errors": errors,
            "probes": probes,
        }, sys.stdout, indent=2)
        sys.stdout.write("\n")
    else:
        print(f"Catalog: {catalog_path}")
        print(f"Total entries: {len(entries)}")
        print("By category:")
        for cat, es in sorted(by_category.items()):
            print(f"  {cat:12} {len(es):3}")
        if errors:
            print("\nValidation errors:")
            for err in errors:
                print(f"  - {err}")
        if args.list:
            print("\nEntries:")
            for e in sorted(entries, key=lambda x: (x.get("category", ""), x.get("slug", ""))):
                print(f"  [{e.get('category','?')}] {e['slug']:26} {e.get('title','')}")
        if probes:
            print("\nProbes:")
            for p in probes:
                print(f"  {str(p['status']):20} {p['slug']}")

    exit_bad = bool(errors)
    if args.probe:
        for p in probes:
            s = p["status"]
            if isinstance(s, int) and (s < 200 or s >= 400):
                exit_bad = True
            if isinstance(s, str) and s.startswith("ERR("):
                exit_bad = True
    sys.exit(1 if exit_bad else 0)


if __name__ == "__main__":
    main()
