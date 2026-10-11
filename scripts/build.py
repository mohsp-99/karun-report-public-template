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
    parser.add_argument("--clean", action="store_true", help="Remove temporary typst/build after inspection; preserve output PDFs")
    args = parser.parse_args()
    build = TYPST / "build"
    if args.clean:
        if args.examples or args.render:
            parser.error("Run --clean separately after inspecting rendered pages")
        if build.is_symlink() or build.resolve() != TYPST.resolve() / "build":
            parser.exit(1, "Refusing to clean a redirected build directory.\n")
        if build.exists():
            shutil.rmtree(build)
        print("Temporary build files removed; output PDFs and source files preserved.")
        return 0
    if args.ppi <= 0:
        parser.error("--ppi must be positive")
    binary = shutil.which("typst")
    if binary is None:
        parser.exit(1, "Typst is not on PATH. Install Typst, then rerun this command.\n")
    sources = [TYPST / "report/report.typ"]
    if args.examples:
        sources.extend(sorted((TYPST / "examples").glob("*.typ")))
    deliverables = ROOT / "output"
    deliverables.mkdir(exist_ok=True)
    for source in sources:
        base = [binary, "compile", "--root", str(TYPST), "--font-path", str(TYPST / "fonts"), str(source)]
        output = deliverables / f"{source.stem}.pdf"
        print(f"Building {source.relative_to(ROOT)} -> {output.relative_to(ROOT)}", flush=True)
        subprocess.run([*base, str(output)], check=True, cwd=ROOT)
        if args.render:
            build.mkdir(exist_ok=True)
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
