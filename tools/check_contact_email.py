#!/usr/bin/env python3
"""Fails if any contact address other than the project's fixed one appears.

The published privacy policy shipped with drbetances@hotmail.com in six places
while the project rule fixes a single contact address for the privacy policy,
the Play Console listing and every legal document. A rule that only lives in a
document gets broken silently, so it lives here too.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

CONTACT_EMAIL = "frank.alberto.betances.reinoso@gmail.com"

ROOT = Path(__file__).resolve().parent.parent

# Scanned: everything a reader or a store reviewer can end up looking at.
SCAN_SUFFIXES = {".html", ".md", ".json", ".dart", ".yaml", ".yml", ".xml", ".txt", ".kt"}

SKIP_DIRS = {
    ".git",
    "build",
    ".dart_tool",
    # Antigravity's own agent workspace: configuration this project does not own.
    ".agents",
    # Third-party code, not project content: docs/build-pdf.js needs playwright,
    # and its own documentation carries example addresses.
    "node_modules",
}

EMAIL_RE = re.compile(r"[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}")

# Addresses that are examples inside documentation about this very rule, not
# contact points offered to anyone.
ALLOWED = {CONTACT_EMAIL, "noreply@anthropic.com"}


def main() -> int:
    offenders: list[str] = []

    for path in sorted(ROOT.rglob("*")):
        if not path.is_file() or path.suffix.lower() not in SCAN_SUFFIXES:
            continue
        if any(part in SKIP_DIRS for part in path.relative_to(ROOT).parts):
            continue

        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue

        for lineno, line in enumerate(text.splitlines(), start=1):
            for found in EMAIL_RE.findall(line):
                if found not in ALLOWED:
                    rel = path.relative_to(ROOT)
                    offenders.append(f"{rel}:{lineno}: {found}")

    if offenders:
        print("FAIL: contact addresses other than the project's fixed one:", file=sys.stderr)
        for entry in offenders:
            print(f"  {entry}", file=sys.stderr)
        print(f"\nThe only contact address for this project is {CONTACT_EMAIL}.", file=sys.stderr)
        return 1

    print(f"OK: the only contact address in the repository is {CONTACT_EMAIL}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
