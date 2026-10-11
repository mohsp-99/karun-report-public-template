#!/usr/bin/env python3
"""Build reports and regression examples with consistent Typst paths."""

import argparse
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
TYPST = ROOT / "typst"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--examples", action="store_true", help="Also build all regression examples")
    parser.add_argument("--render", action="store_true", help="Also render PNG pages for inspection")
    parser.add_argument("--ppi", type=int, default=100, help="PNG resolution (default: 100)")
    args = parser.parse_args()
    if args.ppi <= 0:
        parser.error("--ppi must be positive")
    binary = shutil.which("typst")
    if binary is None:
        parser.exit(1, "Typst is not on PATH. Install Typst, then rerun this command.\n")
    sources = [TYPST / "report/report.typ"]
    if args.examples:
        sources.extend(sorted((TYPST / "examples").glob("*.typ")))
    build = TYPST / "build"
    build.mkdir(exist_ok=True)
    for source in sources:
        base = [binary, "compile", "--root", str(TYPST), "--font-path", str(TYPST / "fonts"), str(source)]
        output = build / f"{source.stem}.pdf"
        print(f"Building {source.relative_to(ROOT)} -> {output.relative_to(ROOT)}", flush=True)
        subprocess.run([*base, str(output)], check=True, cwd=ROOT)
        if args.render:
            # Unique directories prevent old pages surviving a shorter new report.
            pages = Path(tempfile.mkdtemp(prefix=f"{source.stem}-pages-", dir=build))
            subprocess.run([*base, str(pages / "page-{p}.png"), "--format", "png", "--ppi", str(args.ppi)], check=True, cwd=ROOT)
            print(f"Rendered pages: {pages.relative_to(ROOT)}", flush=True)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except subprocess.CalledProcessError as error:
        sys.exit(error.returncode)
