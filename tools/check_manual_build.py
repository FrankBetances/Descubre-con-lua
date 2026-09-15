#!/usr/bin/env python3
"""Fails when the manual's PDF or Word are older than the HTML they come from.

docs/manual-casos-de-uso.html is the single source; the PDF and the Word are
generated from it. This check exists because of what happens without it: the
source moves on, the generated Word keeps describing an earlier version, and
nothing says so.

Each builder stamps the hash of the HTML it read. This compares those stamps
with the file on disk.
"""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"
SRC = DOCS / "manual-casos-de-uso.html"
STAMP = DOCS / ".manual-build-stamp.json"

OUTPUTS = {
    "pdf": ("Descubre-con-Lua-Manual-Casos-de-Uso.pdf", "node docs/build-pdf.js"),
    "docx": ("Descubre-con-Lua-Manual-Casos-de-Uso.docx", "python3 docs/build-docx.py"),
}


def main() -> int:
    if not SRC.exists():
        print(f"FAIL: the manual's source is missing: {SRC.name}", file=sys.stderr)
        return 1

    digest = hashlib.sha256(SRC.read_bytes()).hexdigest()
    stamp = json.loads(STAMP.read_text(encoding="utf-8")) if STAMP.exists() else {}

    failures: list[str] = []
    for kind, (filename, command) in OUTPUTS.items():
        target = DOCS / filename
        if not target.exists():
            failures.append(f"{filename} does not exist — run: {command}")
        elif stamp.get(kind) != digest:
            failures.append(
                f"{filename} was built from an older {SRC.name} — run: {command}"
            )

    if failures:
        print("FAIL: the manual's generated documents are stale:", file=sys.stderr)
        for line in failures:
            print(f"  {line}", file=sys.stderr)
        return 1

    print(f"OK: the PDF and the Word both come from the current {SRC.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
