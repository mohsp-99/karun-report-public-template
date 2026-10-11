---
name: karun-report-typst
description: Create, edit, or validate Karun Typst reports in English or Persian/RTL using supplied content, branded tables, diagrams, and pagination.
---

# Karun Report — Typst (PDF)

This is a repository-local skill. Work from the repository root (containing
AGENTS.md and typst/), not from this skill directory. Read AGENTS.md for editing
boundaries and validation commands. Code snippets belong in
`typst/report/report.typ`; imports and figure paths are relative to that file.

Use user-provided content and let the template own typography, RTL behavior,
tables, branding, and pagination.

## Boundaries

- Routine report generation may edit `typst/report/metadata.typ`, `typst/report/report.typ`, and add
  user-provided report assets to `typst/report/figures/`.
- Edit engines, fonts, brand assets, and shared examples only for an explicit
  template-maintenance request; add a focused regression example when relevant.
- Never invent facts, numbers, sources, metadata, quotations, diagram labels, or
  conclusions. Infer organization, not content. Ask for material missing data or
  leave an explicit placeholder if the user prefers.
- Preserve unrelated user work. Never use a wholesale history revert for a
  focused correction.

## Workflow

For Persian prose, also use [persian-writing](../persian-writing/SKILL.md).
First read [the Karun integration rules](../../../docs/persian-writing.md),
then its writing-style and orthography references. Use it to improve wording
within the user's requested scope; this template still owns Typst layout,
fonts, technical-token handling, and the ezafe spelling below. Its cleanup
scripts are prose tools, not Typst parsers: never apply them to `.typ` files.

1. Determine whether the report is English or Persian. Collect only supplied
   metadata and body content. Classification values are `access_level`: 1
   Internal, 2 External, 3 Public; and `confidentiality`: 1 Normal, 2
   Confidential, 3 Top Secret.
2. Fill `typst/report/metadata.typ` using only supplied or user-confirmed values.
3. In `typst/report/report.typ`, set the same language on all three setup calls:

   ```typ
   #show: karun-report.with(lang: "fa", meta: meta)
   #title-page(meta, lang: "fa")
   #contents-page(lang: "fa")
   ```

   Use `"en"` on all three for English. Mixed values are invalid.
4. Replace the placeholder body. Preserve supplied meaning unless the user asks
   for editing or rewriting.
5. For Persian reports, scan only user-authored Persian content in `typst/report/report.typ`
   and `typst/report/metadata.typ` and normalize mistaken characters to the template's
   ی-style spelling: `ة` becomes `ی`, and the hamza ezafe forms `هٔ` and `ۀ`
   become `ه‌ی` (heh + ZWNJ + ی), e.g. `نمونهٔ` → `نمونه‌ی`. This must happen
   in the source — the engine performs no substitution (render-time replacement
   breaks letter joining, and B Nazanin renders `هٔ` as empty boxes). Do not
   globally alter engine code, identifiers, file names, or intentionally quoted
   Arabic text.
6. Compile from the repository root:

   ```text
   python scripts/build.py
   ```

   The build script supplies the project root and font path. With no Python, use
   `typst compile --root typst --font-path typst/fonts typst/report/report.typ output/report.pdf`. Fix relevant errors and warnings, then
   inspect the PDF or rendered pages for RTL direction, font fallback, clipping,
   isolated headings, crowded tables, and blank pages. Recompile after fixes.
   If Typst is unavailable, preserve the source and give the exact command; do
   not claim PDF validation.

## Markup and pagination

- `= Section` and `== Subsection` create numbered Karun-blue headings.
- `#heading(level: 1, numbering: none)[Executive Summary]` is unnumbered but
  remains in the table of contents.
- Use `*bold*`, `_italic_`, `` `code` ``, `- item`, and blank-line paragraphs.
- Use `#figure(image("figures/x.png", width: 100%), caption: [ ... ])` for an
  image with its caption below it.
- Put `#keep-with-next[Short lead-in.]` immediately before its figure or table
  so the lead-in is not stranded at the bottom of a page.
- Wrap compact content that must stay on one page in `#keep-together[...]`. Do
  not use this unbreakable helper around content too tall to fit on a page.

## Tables

Create report tables as table figures and identify their header:

```typ
#figure(
  table(
    columns: 3,
    table.header([Item], [Owner], [Status]),
    [Measurement], [Engineering], [Complete],
  ),
  caption: [Project status.],
)
```

The engine automatically applies Karun blue, white header text, blue-tinted
rules, smaller table type, and slightly smaller Latin text inside Persian
reports. Do not reproduce these styles inline or manually resize Latin terms.

Use `#keep-together[...]` for a genuinely short intro/table unit. Ordinary table
figures stay intact. A table too tall for one page must use `#long-table[...]`
and repeat its explicit header:

```typ
#long-table[
  #figure(
    table(
      columns: 3,
      table.header(repeat: true, [Item], [Owner], [Status]),
      [Measurement], [Engineering], [Complete],
      // More supplied rows ...
    ),
    caption: [Project status.],
  )
]
```

Never force a multi-page table into `#keep-together[...]`.

## Diagrams and Persian / RTL

For diagrams, read [docs/diagrams.md](../../../docs/diagrams.md) and use only labels and values already in the
report. Diagrams visualize supplied facts; they never invent them.

For Persian, set `lang: "fa"` on all three setup calls. The engine automatically
selects RTL layout, B Nazanin body text, Persian branding/labels/numbers,
smaller Dubai-rendered Latin runs, and branded tables. Type tokens such as
`ANT02-A0000`, `ISO 2768`, and `215 MPa` normally; do not fake direction with
spaces or Unicode controls. The cover legal disclaimer stays English by design.

## Hand-numbered Persian style (karun-fa-style)

When the user asks for a Persian report in the hand-numbered house style —
section numbers written in the heading text, Dubai body type, table captions
above / figure captions below — import `../template/karun-fa-style.typ` after the cover and
contents pages and follow [docs/persian-style.md](../../../docs/persian-style.md) exactly: it prescribes the setup-block
order (a `set text(font: "Dubai")` BEFORE `title-page`, or the cover stays in
B Nazanin), the per-report helpers, the `sn[]`/`lt[]`/`nb[]` bidi discipline
for compound numbers and technical tokens, and the acceptance checks. The
engine `karun.typ` still must not be modified. The compact living reference is
`typst/examples/fa-style-regression.typ`.

For extended markup reference, read [docs/authoring.md](../../../docs/authoring.md).
Load diagram and Persian house-style references only when those modes apply.

## Final delivery and cleanup

Keep the standard branded cover; add a cover image only when explicitly requested
by the user, respecting later corrections over source design comments. Final
PDFs belong in `output/`. After visual checks, run
`python scripts/build.py --clean` to remove temporary `typst/build/` contents and
the directory itself. Retain the final PDF, editable sources, and supplied assets.
Link the final PDF and report any source issues; do not leave review artifacts.
