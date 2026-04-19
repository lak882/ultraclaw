#!/usr/bin/env python3
"""
Pull InterSystems documentation pages and convert them to Markdown.

Fetches a doc page from an IRIS server's built-in DocBook or from
docs.intersystems.com and extracts the actual content as clean Markdown.

Usage:
    irispython pull_docs.py --key GCRN_new20261
    irispython pull_docs.py --key GCRN_new20261 --version 2024.1
    irispython pull_docs.py --key GCRN_new20261 --product irishealth --version 2025.2
    irispython pull_docs.py --key GCRN_new20261 --server vmdev1
    irispython pull_docs.py --url "https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GINTEROP"
    irispython pull_docs.py --key GCRN_new20261 --output docs/release-notes-2026.1.md
    irispython pull_docs.py --key GCRN_new20261 --list-keys
    irispython pull_docs.py --search "interop editor"
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import argparse
import json
import os
import re
import sys
import urllib.request
import urllib.error
import base64
from html.parser import HTMLParser


# ---------------------------------------------------------------------------
# HTML-to-Markdown converter
# ---------------------------------------------------------------------------

class DocBookToMarkdown(HTMLParser):
    """Convert DocBook HTML content to Markdown."""

    def __init__(self):
        super().__init__()
        self.output = []
        self.current_line = ""
        self.tag_stack = []
        self.list_stack = []  # track ol/ul nesting
        self.list_counter = []  # for ordered lists
        self.in_pre = False
        self.in_code = False
        self.in_table = False
        self.table_row = []
        self.table_rows = []
        self.skip_tags = {"script", "style", "nav", "button", "noscript", "iframe"}
        self.skipping = 0
        self.in_link = False
        self.link_href = ""
        self.link_text = ""
        self.suppress_whitespace = False

    def _flush(self):
        if self.current_line.strip():
            self.output.append(self.current_line)
        self.current_line = ""

    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)
        tag_lower = tag.lower()

        # Skip chrome elements
        if tag_lower in self.skip_tags:
            self.skipping += 1
            return
        if self.skipping:
            return

        # Skip elements with data-swiftype-index="false" (nav chrome)
        if attrs_dict.get("data-swiftype-index") == "false":
            self.skipping += 1
            return

        self.tag_stack.append(tag_lower)

        if tag_lower in ("h1", "h2", "h3", "h4", "h5", "h6"):
            self._flush()
            level = int(tag_lower[1])
            self.output.append("")
            self.current_line = "#" * level + " "

        elif tag_lower == "p":
            self._flush()
            self.output.append("")
            self.current_line = ""

        elif tag_lower == "br":
            self._flush()

        elif tag_lower == "pre":
            self._flush()
            self.output.append("")
            self.output.append("```")
            self.in_pre = True

        elif tag_lower == "code" and not self.in_pre:
            self.current_line += "`"
            self.in_code = True

        elif tag_lower in ("strong", "b"):
            self.current_line += "**"

        elif tag_lower in ("em", "i"):
            self.current_line += "*"

        elif tag_lower == "a":
            href = attrs_dict.get("href", "")
            if href and not href.startswith("#") and not href.startswith("javascript"):
                self.in_link = True
                self.link_href = href
                self.link_text = ""

        elif tag_lower == "ul":
            self._flush()
            self.list_stack.append("ul")
            self.list_counter.append(0)

        elif tag_lower == "ol":
            self._flush()
            self.list_stack.append("ol")
            self.list_counter.append(0)

        elif tag_lower == "li":
            self._flush()
            indent = "  " * max(0, len(self.list_stack) - 1)
            if self.list_stack and self.list_stack[-1] == "ol":
                self.list_counter[-1] += 1
                self.current_line = f"{indent}{self.list_counter[-1]}. "
            else:
                self.current_line = f"{indent}- "

        elif tag_lower == "table":
            self._flush()
            self.in_table = True
            self.table_rows = []
            self.output.append("")

        elif tag_lower in ("tr",):
            self.table_row = []

        elif tag_lower in ("td", "th"):
            pass  # collect text in handle_data

        elif tag_lower == "blockquote":
            self._flush()
            self.output.append("")
            self.current_line = "> "

        elif tag_lower == "hr":
            self._flush()
            self.output.append("")
            self.output.append("---")
            self.output.append("")

        elif tag_lower == "img":
            alt = attrs_dict.get("alt", "")
            if alt and "icon" not in alt.lower():
                self.current_line += f"[{alt}]"

    def handle_endtag(self, tag):
        tag_lower = tag.lower()

        if tag_lower in self.skip_tags:
            self.skipping = max(0, self.skipping - 1)
            return
        if self.skipping:
            # Check if this closes a skipped data-swiftype element
            if tag_lower in ("header", "nav", "div", "span"):
                pass  # These might close the skipped parent
            return

        if self.tag_stack and self.tag_stack[-1] == tag_lower:
            self.tag_stack.pop()

        if tag_lower in ("h1", "h2", "h3", "h4", "h5", "h6"):
            self._flush()
            self.output.append("")

        elif tag_lower == "p":
            self._flush()

        elif tag_lower == "pre":
            self._flush()
            self.output.append("```")
            self.output.append("")
            self.in_pre = False

        elif tag_lower == "code" and not self.in_pre:
            self.current_line += "`"
            self.in_code = False

        elif tag_lower in ("strong", "b"):
            self.current_line += "**"

        elif tag_lower in ("em", "i"):
            self.current_line += "*"

        elif tag_lower == "a":
            if self.in_link and self.link_text.strip():
                self.current_line += f"[{self.link_text.strip()}]({self.link_href})"
                self.in_link = False
                self.link_href = ""
                self.link_text = ""
            elif self.in_link:
                self.in_link = False

        elif tag_lower in ("ul", "ol"):
            self._flush()
            if self.list_stack:
                self.list_stack.pop()
            if self.list_counter:
                self.list_counter.pop()

        elif tag_lower == "li":
            self._flush()

        elif tag_lower in ("td", "th"):
            self.table_row.append(self.current_line.strip())
            self.current_line = ""

        elif tag_lower == "tr":
            if self.table_row:
                self.table_rows.append(self.table_row)
            self.table_row = []

        elif tag_lower == "table":
            if self.table_rows:
                self._render_table()
            self.in_table = False
            self.output.append("")

    def handle_data(self, data):
        if self.skipping:
            return

        if self.in_link:
            self.link_text += data
            return

        if self.in_pre:
            self.output.append(data.rstrip())
            return

        # Normalize whitespace for non-pre content
        text = data
        if not self.in_pre:
            text = re.sub(r"\s+", " ", text)
            if not self.current_line and text.startswith(" "):
                text = text.lstrip()

        self.current_line += text

    def handle_entityref(self, name):
        entities = {
            "amp": "&", "lt": "<", "gt": ">", "quot": '"',
            "nbsp": " ", "reg": "(R)", "copy": "(C)",
            "mdash": "--", "ndash": "-", "hellip": "...",
            "rsquo": "'", "lsquo": "'", "rdquo": '"', "ldquo": '"',
        }
        char = entities.get(name, f"&{name};")
        if self.in_link:
            self.link_text += char
        else:
            self.current_line += char

    def handle_charref(self, name):
        try:
            if name.startswith("x"):
                char = chr(int(name[1:], 16))
            else:
                char = chr(int(name))
        except (ValueError, OverflowError):
            char = f"&#{name};"
        if self.in_link:
            self.link_text += char
        else:
            self.current_line += char

    def _render_table(self):
        if not self.table_rows:
            return
        # Determine column widths
        max_cols = max(len(r) for r in self.table_rows)
        # Pad rows
        for row in self.table_rows:
            while len(row) < max_cols:
                row.append("")
        col_widths = [
            max(len(self.table_rows[r][c]) for r in range(len(self.table_rows)))
            for c in range(max_cols)
        ]
        col_widths = [max(w, 3) for w in col_widths]

        # Render header
        header = self.table_rows[0]
        header_line = "| " + " | ".join(
            header[c].ljust(col_widths[c]) for c in range(max_cols)
        ) + " |"
        sep_line = "| " + " | ".join(
            "-" * col_widths[c] for c in range(max_cols)
        ) + " |"
        self.output.append(header_line)
        self.output.append(sep_line)
        for row in self.table_rows[1:]:
            row_line = "| " + " | ".join(
                row[c].ljust(col_widths[c]) for c in range(max_cols)
            ) + " |"
            self.output.append(row_line)

    def get_markdown(self):
        self._flush()
        text = "\n".join(self.output)
        # Clean up excessive blank lines
        text = re.sub(r"\n{3,}", "\n\n", text)
        return text.strip()


# ---------------------------------------------------------------------------
# Fetching
# ---------------------------------------------------------------------------

def load_server_config(server_name):
    """Load server config from servers.json."""
    config_path = os.path.join(os.path.dirname(__file__), "..", "..", "..", "..", "config", "servers.json")
    config_path = os.path.normpath(config_path)
    if not os.path.exists(config_path):
        # Try from cwd
        config_path = os.path.join("config", "servers.json")
    with open(config_path) as f:
        data = json.load(f)
    servers = data.get("intersystems.servers", data)
    if server_name not in servers:
        print(f"ERROR: Server '{server_name}' not found. Available: {', '.join(servers.keys())}", file=sys.stderr)
        sys.exit(1)
    return servers[server_name]


def build_doc_url(key, server=None, version=None, product=None):
    """Build the URL for a DocBook page.

    Product determines the URL path prefix on docs.intersystems.com:
      iris         -> /iris{ver}/   (default)
      irishealth   -> /irishealth{ver}/
      hs (alias)   -> /irishealth{ver}/
      hslatest     -> /irishealthlatest/
      e (ensemble) -> /ensemble{ver}/
      latest       -> /irislatest/  (default when no version)

    When using --server, product is ignored (the local DocBook serves
    all docs regardless of product).
    """
    if server:
        srv = load_server_config(server)
        ws = srv["webServer"]
        base = f"{ws['scheme']}://{ws['host']}:{ws['port']}{ws.get('pathPrefix', '')}"
        return base + f"/csp/docbook/DocBook.UI.Page.cls?KEY={key}", srv
    else:
        # Resolve product name to URL path prefix
        product = (product or "iris").lower().strip()
        product_map = {
            "iris": "iris",
            "irisforhealth": "irisforhealth",
            "irishealth": "irisforhealth",
            "hs": "irisforhealth",
            "healthshare": "irisforhealth",
            "health": "irisforhealth",
            "ensemble": "ensemble",
            "e": "ensemble",
            "cache": "cache",
            "healthconnect": "irisforhealth",
            "hc": "irisforhealth",
        }
        product_prefix = product_map.get(product, product)

        if version:
            ver_slug = version.replace(".", "")
            ver_path = f"{product_prefix}{ver_slug}"
        else:
            ver_path = f"{product_prefix}latest"

        url = f"https://docs.intersystems.com/{ver_path}/csp/docbook/DocBook.UI.Page.cls?KEY={key}"
        return url, None


def fetch_page(url, server_config=None):
    """Fetch a documentation page."""
    headers = {}
    if server_config:
        username = server_config.get("username", "")
        password = server_config.get("password", "")
        creds = base64.b64encode(f"{username}:{password}".encode()).decode()
        headers["Authorization"] = f"Basic {creds}"

    req = urllib.request.Request(url, headers=headers)
    try:
        resp = urllib.request.urlopen(req, timeout=30)
        return resp.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as e:
        # If irisforhealth returns 403, try falling back to iris
        if e.code == 403 and "irisforhealth" in url:
            fallback_url = url.replace("/irisforhealth", "/iris")
            print(f"WARNING: {url} returned 403, trying {fallback_url}...", file=sys.stderr)
            req2 = urllib.request.Request(fallback_url, headers=headers)
            try:
                resp2 = urllib.request.urlopen(req2, timeout=30)
                return resp2.read().decode("utf-8", errors="replace")
            except urllib.error.HTTPError as e2:
                print(f"ERROR: HTTP {e2.code} fetching {fallback_url} (fallback also failed)", file=sys.stderr)
                sys.exit(1)
        print(f"ERROR: HTTP {e.code} fetching {url}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)


def extract_content(html):
    """Extract the main documentation content from the HTML page."""
    # Strategy: find the first <h1> tag (actual content) and extract until footer/end
    h1_match = re.search(r"<h1[^>]*>", html)
    if not h1_match:
        # Fallback: try to find content after the left nav
        # Look for the content area after </nav> sections
        nav_end = html.rfind("</nav>")
        if nav_end > 0:
            content_html = html[nav_end + 6:]
        else:
            content_html = html
    else:
        start = h1_match.start()
        # Find the end boundary
        footer = html.find("<footer", start)
        if footer < 0:
            footer = html.find("</main>", start)
        if footer < 0:
            footer = len(html)
        content_html = html[start:footer]

    # Remove script/style tags
    content_html = re.sub(r"<script[^>]*>.*?</script>", "", content_html, flags=re.DOTALL)
    content_html = re.sub(r"<style[^>]*>.*?</style>", "", content_html, flags=re.DOTALL)

    # Remove "skip to content" and other chrome divs
    content_html = re.sub(r'<div[^>]*class="[^"]*search[^"]*"[^>]*>.*?</div>', "", content_html, flags=re.DOTALL)
    content_html = re.sub(r'<div[^>]*class="[^"]*chatbot[^"]*"[^>]*>.*?</div>', "", content_html, flags=re.DOTALL)
    content_html = re.sub(r'<div[^>]*id="topspace"[^>]*>.*?</div>\s*</div>\s*</div>', "", content_html, flags=re.DOTALL)

    return content_html


def extract_doc_keys(html):
    """Extract all KEY= references from a page for navigation."""
    keys = re.findall(r'KEY=([A-Za-z0-9_]+)', html)
    # Deduplicate while preserving order
    seen = set()
    unique = []
    for k in keys:
        if k not in seen:
            seen.add(k)
            unique.append(k)
    return unique


def search_keys(html, query):
    """Search for doc keys matching a query by looking at link text."""
    results = []
    pattern = re.compile(
        r'<[Aa][^>]*href="[^"]*KEY=([A-Za-z0-9_]+)"[^>]*(?:title="([^"]*)")?[^>]*>(.*?)</[Aa]>',
        re.DOTALL
    )
    query_lower = query.lower()
    for match in pattern.finditer(html):
        key = match.group(1)
        title = match.group(2) or ""
        link_text = re.sub(r"<[^>]+>", "", match.group(3)).strip()
        searchable = f"{key} {title} {link_text}".lower()
        if query_lower in searchable:
            desc = title if title else link_text
            results.append((key, desc))
    # Deduplicate
    seen = set()
    unique = []
    for key, desc in results:
        if key not in seen:
            seen.add(key)
            unique.append((key, desc))
    return unique


def html_to_markdown(html_content):
    """Convert HTML content to Markdown."""
    converter = DocBookToMarkdown()
    converter.feed(html_content)
    return converter.get_markdown()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Pull InterSystems documentation as Markdown")
    parser.add_argument("--key", help="Documentation key (e.g., GCRN_new20261, GINTEROP)")
    parser.add_argument("--url", help="Full documentation URL to fetch")
    parser.add_argument("--server", help="IRIS server name from servers.json (uses local DocBook)")
    parser.add_argument("--version", help="IRIS version for docs.intersystems.com (e.g., 2024.1). Default: latest")
    parser.add_argument("--product", default="irisforhealth",
                        help="Product name for docs.intersystems.com URL path. "
                             "Options: irisforhealth (default), iris, ensemble/e, cache. "
                             "Aliases: hs/health/irishealth/hc -> irisforhealth")
    parser.add_argument("--output", "-o", help="Save output to file instead of stdout")
    parser.add_argument("--list-keys", action="store_true", help="List all doc keys referenced on the page")
    parser.add_argument("--search", help="Search for doc keys matching a query")
    parser.add_argument("--raw", action="store_true", help="Output raw extracted HTML instead of Markdown")

    args = parser.parse_args()

    if not args.key and not args.url and not args.search:
        parser.error("One of --key, --url, or --search is required")

    # If searching, we need a base page to search in
    if args.search:
        key = args.key or "GINTEROP"  # Default to interop TOC
        url, srv_config = build_doc_url(key, server=args.server, version=args.version, product=args.product)
        print(f"Searching '{args.search}' in {key}...", file=sys.stderr)
        html = fetch_page(url, srv_config)
        results = search_keys(html, args.search)
        if results:
            print(f"\nFound {len(results)} matching doc keys:\n")
            for doc_key, desc in results:
                print(f"  {doc_key:40s}  {desc}")
            print(f"\nUse: irispython {sys.argv[0]} --key <KEY> to fetch a page")
        else:
            print(f"No matches for '{args.search}' in {key}")
        return

    # Fetch the page
    if args.url:
        url = args.url
        # Try to extract KEY from URL for metadata
        key_match = re.search(r"KEY=([A-Za-z0-9_]+)", url)
        key = key_match.group(1) if key_match else "unknown"
        srv_config = None
        if args.server:
            srv_config = load_server_config(args.server)
    else:
        key = args.key
        url, srv_config = build_doc_url(key, server=args.server, version=args.version, product=args.product)

    print(f"Fetching {url}...", file=sys.stderr)
    html = fetch_page(url, srv_config)
    print(f"Page size: {len(html):,} bytes", file=sys.stderr)

    # List keys mode
    if args.list_keys:
        keys = extract_doc_keys(html)
        print(f"\nDoc keys referenced on {key}:\n")
        for k in keys:
            print(f"  {k}")
        print(f"\nTotal: {len(keys)} keys")
        return

    # Extract content
    content_html = extract_content(html)
    if not content_html.strip():
        print("WARNING: No content found on page. This may be a navigation-only page.", file=sys.stderr)
        print("Try --list-keys to see linked pages, or --search to find specific topics.", file=sys.stderr)
        sys.exit(1)

    if args.raw:
        result = content_html
    else:
        result = html_to_markdown(content_html)

    # Add metadata header
    version_info = args.version or "latest"
    if srv_config:
        ws = srv_config["webServer"]
        source = f"{ws['host']}:{ws['port']} ({ws.get('pathPrefix', '')})"
    else:
        source = f"docs.intersystems.com ({version_info})"

    header = f"<!-- Source: {source} | Key: {key} -->\n\n"
    result = header + result

    if args.output:
        os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)
        with open(args.output, "w") as f:
            f.write(result)
        print(f"Saved to {args.output} ({len(result):,} chars)", file=sys.stderr)
    else:
        print(result)


if __name__ == "__main__":
    main()
