#!/usr/bin/env python3
"""Regenerate index.json and/or baseline.json for the skills-editor.

index.json    = current state of .claude/ (refreshed frequently)
baseline.json = original shipped state from skills-backup/ (regenerated rarely)

Usage:
  python3 refresh-index.py                  # regenerate index.json only
  python3 refresh-index.py --baseline       # regenerate both index.json and baseline.json
  python3 refresh-index.py --baseline-only  # regenerate baseline.json only
"""
import json
import os
import sys

# Resolve paths relative to this script's location
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DOT_CLAUDE = os.path.join(SCRIPT_DIR, '..', '..', '.claude')
SKILLS_BACKUP = os.path.join(SCRIPT_DIR, '..', '..', '.claude', 'skills', 'skills-editor', 'skills-backup')
INDEX_OUT = os.path.join(SCRIPT_DIR, 'index.json')
BASELINE_OUT = os.path.join(SCRIPT_DIR, 'baseline.json')

# Files/dirs to skip
SKIP_NAMES = {'__pycache__', '.DS_Store', 'skills-editor'}
SKIP_EXTS = {'.pyc', '.pyo'}


def scan_directory(root_dir):
    """Walk a directory and return a sorted list of file entries."""
    entries = []
    root_dir = os.path.realpath(root_dir)
    if not os.path.isdir(root_dir):
        return entries

    for dirpath, dirnames, filenames in os.walk(root_dir):
        # Filter out skipped directories
        dirnames[:] = [d for d in dirnames if d not in SKIP_NAMES]
        dirnames.sort()

        for fname in sorted(filenames):
            if fname in SKIP_NAMES:
                continue
            ext = os.path.splitext(fname)[1]
            if ext in SKIP_EXTS:
                continue

            full_path = os.path.join(dirpath, fname)
            rel_path = os.path.relpath(full_path, root_dir)

            # Determine section from top-level directory
            parts = rel_path.replace(os.sep, '/').split('/')
            section = parts[0] if len(parts) > 1 and parts[0] in ('skills', 'commands', 'hooks', 'context') else ''

            try:
                size = os.path.getsize(full_path)
            except OSError:
                size = 0

            entries.append({
                'path': rel_path.replace(os.sep, '/'),
                'name': fname,
                'section': section,
                'ext': ext,
                'size': size,
            })

    return entries


def write_json(entries, out_path):
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(entries, f, indent=2, ensure_ascii=False)
        f.write('\n')


def main():
    do_index = '--baseline-only' not in sys.argv
    do_baseline = '--baseline' in sys.argv or '--baseline-only' in sys.argv

    if do_index:
        entries = scan_directory(DOT_CLAUDE)
        write_json(entries, INDEX_OUT)
        print(f'index.json: {len(entries)} files')

    if do_baseline:
        entries = scan_directory(SKILLS_BACKUP)
        write_json(entries, BASELINE_OUT)
        print(f'baseline.json: {len(entries)} files')


if __name__ == '__main__':
    main()
