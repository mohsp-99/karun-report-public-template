#!/usr/bin/env python3
"""Mirror canonical Codex skills into Claude Code's discovery directory."""

import argparse
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / ".agents/skills"
TARGET = ROOT / ".claude/skills"


def files(directory):
    return {p.relative_to(directory): p for p in directory.rglob("*") if p.is_file()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Report drift without modifying files")
    args = parser.parse_args()
    source, target = files(SOURCE), files(TARGET)
    if not any(p.name == "SKILL.md" for p in source):
        parser.exit(1, "No canonical skills found.\n")
    stale = target.keys() - source.keys()
    different = [p for p in source if p not in target or source[p].read_bytes() != target[p].read_bytes()]
    for path in sorted(stale):
        print(f"Unexpected mirror file (remove or relocate explicitly): {path}")
    for path in sorted(different):
        if args.check:
            print(f"Missing or changed mirror: {path}")
        else:
            destination = TARGET / path
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(source[path].read_bytes())
            print(f"Synced {path}")
    if stale or (args.check and different):
        return 1
    print("Skill mirrors are synchronized.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
