# Karun report template: agent guide

This repository builds branded English (LTR) and Persian (RTL) PDFs with Typst.
This is the shared guide for Codex and Claude Code. Before writing or modifying
a report, read [the report skill](.agents/skills/karun-report-typst/SKILL.md).
For Persian writing, editing, or translation, also read
[the Persian-writing skill](.agents/skills/persian-writing/SKILL.md) and
[its Karun integration rules](docs/persian-writing.md). Those integration rules
resolve the upstream skill's general defaults for this Typst template: preserve
Karun fonts, layout, ezafe spelling, and technical tokens; never run prose
cleanup directly on `.typ` source.

## Repository map

| Path | Purpose |
| --- | --- |
| `typst/report/report.typ` | Editable report body and language setup |
| `typst/report/metadata.typ` | Editable cover/header metadata |
| `typst/report/figures/` | User-supplied report figures |
| `typst/template/` | Shared engines and `brand/` artwork |
| `typst/fonts/` | Dubai and B Nazanin fonts and provenance notes |
| `typst/examples/` | Diagram and Persian regression documents |
| `output/` | Final deliverable PDFs (gitignored) |
| `typst/build/` | Temporary review files; remove after inspection |
| `docs/` | Authoring, diagram, Persian house-style, maintenance references |
| `.agents/skills/` | Canonical Codex skills |
| `.claude/skills/` | Generated Claude Code skill mirrors |
| `scripts/` | Build, skill synchronization, and Linux setup tools |

## Scope and source of truth

- For ordinary report work, edit the body, metadata, and supplied figures under
  `typst/report/`. Never invent facts, numbers, sources, quotations, diagram
  labels, conclusions, or metadata. Ask for material missing content or use
  clearly marked placeholders when the user wants a draft.
- Shared template, font, brand, and example changes belong to explicitly
  requested template maintenance. For behavior changes, add or extend a relevant
  regression example. Path-only reorganizations should preserve rendered output.
- Let the engine own fonts, heading styles, table branding, and Latin sizing.
  Avoid reproducing those styles inline. Preserve unrelated user work; no
  wholesale history reverts for focused corrections.
- Maintain skills in `.agents/skills/`, then run `python scripts/sync_skills.py`.
  Do not edit Claude mirrors independently. `CLAUDE.md` imports this guide.

## Report invariants

1. Fill metadata with supplied values. `access_level`: 1 Internal, 2 External,
   3 Public. `confidentiality`: 1 Normal, 2 Confidential, 3 Top Secret.
2. Use the same `lang: "en"` or `lang: "fa"` on `karun-report.with`,
   `title-page`, and `contents-page`. An optional `agent:` stamp belongs on
   `title-page` only when requested.
3. Normalize user-authored Persian source as specified in the report skill.
   Preserve deliberately quoted Arabic; never substitute at render time.
4. Use `table.header(...)`. Ordinary table figures stay intact; multi-page
   tables need `#long-table[...]` and `table.header(repeat: true, ...)`.
5. Use `#keep-with-next[...]` for a short lead-in and `#keep-together[...]`
   only for groups that fit on one page. Headings are already sticky.
6. Type ordinary Latin tokens as supplied; the engine handles them. For the
   optional hand-numbered Persian house style, follow
   [docs/persian-style.md](docs/persian-style.md), including setup order and
   `sn` / `lt` / `nb` helpers. This mode is not required for every Persian report.
7. For diagrams, read [docs/diagrams.md](docs/diagrams.md) and visualize only
   supplied facts. Extended markup: [docs/authoring.md](docs/authoring.md).

## Build and validate

Run from the repository root. Python scripts also resolve paths when invoked
from another directory. Python 3.10+ and Typst 0.15.1 are the tested baseline.

```sh
python scripts/build.py                         # current report PDF
python scripts/build.py --examples              # report + all regression PDFs
python scripts/build.py --examples --render     # PDFs + PNG pages
python scripts/build.py --clean                  # after visual inspection
python scripts/sync_skills.py --check            # fail on mirror drift
```

Without Python, from the root:

```sh
typst compile --root typst --font-path typst/fonts typst/report/report.typ output/report.pdf
typst compile --root typst --font-path typst/fonts typst/report/report.typ "typst/build/page-{p}.png" --format png --ppi 100
```

Fix compile errors and relevant warnings. Inspect rendered pages for RTL and
mixed-script ordering, missing glyphs, overflow/clipping, table pagination,
stranded headings, and unwanted blank pages. For template or asset path changes,
compile all examples and compare relevant rendered pages. Compilation is not
visual validation: state what was checked and any limitations. If Typst is
unavailable, preserve the source and report the exact build command.

## Maintenance

See [docs/maintenance.md](docs/maintenance.md) for discovery, migration paths,
and CI. Setup scripts must preserve `.git` and existing report files. Generated
reports are local artifacts; template publication does not authorize publishing
a user's report content.

## Finish with a clean workspace

Keep final PDFs in `output/` and all editable sources and supplied assets in
their normal locations. Treat `typst/build/` as disposable review scratch only.
After inspecting the rendered pages, run `python scripts/build.py --clean` to
remove the entire temporary directory. Do not finish with page renders, contact
sheets, comparison baselines, logs, or stale PDFs left in the workspace. Preserve
user files; move any requested deliverable out of scratch before cleanup.
Use the standard branded cover without additional decorative or product images
unless the user explicitly requests them. A later user correction overrides an
embedded source design brief.
