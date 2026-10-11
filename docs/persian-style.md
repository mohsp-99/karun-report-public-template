# FA-STYLE — the hand-numbered Persian report style

How to build a Persian (RTL) report in the hand-numbered house style: Dubai
body text, sections numbered by hand in the heading text, table captions above /
figure captions below, and a strict bidi discipline for numbers and Latin
tokens.

The shared machinery lives in `karun-fa-style.typ` (import it — never re-implement
its helpers per report). `karun.typ` stays untouched: the engine (palette,
cover, running header/footer, TOC machinery, `to-fa-digits`, the Latin-in-Dubai
rule) is correct as shipped, and everything here sits on top of it.
`typst/examples/fa-style-regression.typ` is the compact living reference for all of it.

## 1. The report file's setup block

Reproduce this order exactly at the top of a Persian report. The ordering is not
cosmetic — a Typst `set` rule applies **from its position in the document flow
onward**, so a rule declared after the cover leaves the cover unstyled.

```typ
#import "../template/karun.typ": *
#import "metadata.typ": meta

#show: karun-report.with(lang: "fa", meta: meta)

// Dubai is the company body font, where the engine sets B Nazanin for Persian.
// This MUST come before the title and contents pages, or the cover, the
// metadata table and the table of contents stay in B Nazanin while the body
// runs in Dubai.
#set text(font: "Dubai")

#title-page(meta, lang: "fa")

// The engine's leading is tuned for B Nazanin's tall line-box; in Dubai the
// contents entries sit almost on top of each other. Open the gap between
// entries — this affects the outline only.
#show outline.entry: it => block(above: 12pt, below: 0pt, it)
#contents-page(lang: "fa")

#import "../template/karun-fa-style.typ": *
#show: fa-refine

// Dubai's shorter line-box again: these values land the same ~1.5x line
// spacing the engine gives B Nazanin.
#set text(size: 11.5pt)
#set par(leading: 0.82em, spacing: 1.3em)
```

The contents must stay **one page**; 12 pt between entries is the value that
opens the list up without spilling over. If a report's outline grows, reduce
this rather than letting the TOC run onto a second page.

## 2. What `karun-fa-style.typ` provides

- `fa-refine` — the one document-wide show rule: heading auto-numbering off,
  Latin runs in Dubai at 0.9 em, headings sticky.
- `table-head-fill` / `table-line` / `table-zebra` — the table palette.
- `ktable(breakable: false, zebra: false, ..args)` — the branded table with a
  Karun-blue header band; its first row repeats when the table breaks.
- `ptable(breakable: false, ..args)` — the same look for a key/value table with
  no header row.
- `centred-first` / `centred-but-first` — alignment functions for `align:`,
  matching `|:---:|` columns in source Markdown.
- `note(body)` — block-quote callout with the accent rule on the right (RTL)
  edge.
- `lead(body)` — pins an introductory paragraph to what follows.
- `code(body)` — inline code as a tinted box. **Use this instead of `raw`**:
  the fallback monospace font is not bundled and cannot shape Arabic script, so
  a Persian identifier in `raw` comes out as disconnected letters.
- `todo` — an 8 pt unticked checkbox in Karun blue.
- `fa-enum` — `#show: fa-enum` makes `+` lists number in Persian digits.
- `fa-diagram(body, caption: none)` — numbers a diagram «شکل N», not "Figure N".
- `fa-flow(..steps, per-row: none)` / `fa-chain(..steps)` — Persian
  process-flow / steps-vertical with «گام ۱» counters; `per-row` splits a long
  flow over rows with the ramp and numbering continuous.
- `sn(body)` — compound section numbers, see below.

### `sn` — compound section numbers (the important fix)

A hand-written compound number such as «۸-۲.» renders **wrong** in every naive
form:

- Persian digits U+06F0–06F9 are bidi class **EN**, so «۸-۲» resolves to a
  single left-to-right number run and lays the **chapter number out on the
  left** — the reverse of what is wanted.
- The trailing full stop is not between two digits, so it falls back to the
  paragraph direction and is reordered to the **front**: «.۸-۲».
- **Boxing alone fixes only the full stop.** It makes the token atomic so the
  stop stays at the end, but the digits inside are still one number run and
  still read chapter-left.

Separating the parts with an RTL mark (U+200F) is what pins the order: each
digit group becomes its own run, and the runs lay out right to left — chapter on
the right, section on the left, full stop last. A multi-digit group such as
«۱۰» keeps its own internal left-to-right order, which is correct. `sn` applies
the mark via a show rule on the *separator*, so every call site stays the
literal number.

Use `sn[۸-۲.]` for every compound number — in headings, in contents entries, and
in inline cross-references such as «بند ۸-۱». A plain «۸.» needs no wrapper.

## 3. Local helpers to define in the report file

These are per-report, not library-level, because their tuning is content-driven.

```typ
// Level-1 sections open a new page — but by an explicit call before each
// heading rather than a blanket show rule, so short sections can be exempted.
// `weak` makes it a no-op when the section already starts a page.
#let newsec() = pagebreak(weak: true)

// A figure at an explicit fraction of the column width. `sticky` keeps it with
// the caption that follows; `breakable: false` stops the frame splitting.
#let fig(file, width: 100%) = block(
  width: 100%, breakable: false, sticky: true,
  align(center, image(file, width: width)),
)

// Figure caption — BELOW the figure: centred, 9pt, muted, italic.
#let fig-caption(body) = block(above: 7pt, below: 16pt, width: 100%)[
  #set align(center)
  #set par(justify: false)
  #text(size: 9pt, fill: rgb(90, 100, 114), style: "italic")[#body]
]

// Table caption — ABOVE the table: centred, 9.5pt, Karun blue, `sticky` so it
// cannot be separated from the table it introduces.
#let tbl-caption(body) = block(above: 14pt, below: 6pt, width: 100%, sticky: true)[
  #set align(center)
  #set par(justify: false)
  #text(size: 9.5pt, fill: karun-blue, weight: "medium")[#body]
]

// A footnote sitting directly under a table: 9pt, muted, justified.
#let tnote(body) = block(above: 6pt, below: 16pt, width: 100%)[
  #set par(justify: true, leading: 0.7em)
  #text(size: 9pt, fill: rgb(90, 100, 114))[#body]
]

// Price tables carry the weight of the commercial section: 11.5pt type, a
// deeper header band, generous padding, centred cells.
#let price-table(..args) = block(breakable: false)[
  #set par(justify: false)
  #set text(size: 11.5pt)
  #set table(
    inset: (x: 13pt, y: 10pt),
    stroke: 0.8pt + table-line,
    fill: (_, y) => if y == 0 { karun-blue.lighten(80%) } else { none },
    align: center + horizon,
  )
  #show table.cell.where(y: 0): set text(weight: "bold", fill: karun-blue)
  #table(..args)
]

// Keeps a mixed Latin/Persian token whole — a model code «A-۱» — while leaving
// it laid out right to left, so the Latin letter stays on the right.
#let nb(body) = box(body)

// A wholly Latin technical token: «175 mm», «10 m/s²», «IEC 61587-1». A token
// opening with digits is bidi class EN, so the space before its unit resolves
// to the paragraph level and an RTL line renders it "mm 175". The LTR box pins
// the order and keeps the token unbreakable.
#let lt(body) = box(text(dir: ltr, body))
```

## 4. Layout rules the output must obey

1. **Page break before every level-1 section**, called explicitly with
   `#newsec()` before the heading. **Exempt the very short sections** — one lead
   paragraph plus a single list or table — which would otherwise stand on a
   two-thirds-empty page; let those run on from the section before. Choose breaks according to the current report content.
2. **Table captions above** («جدول ن — …»), **figure captions below**
   («شکل ن — …»). Both numbered by hand in Persian digits, since heading and
   figure auto-numbering is off.
3. **Every figure carries an explicit width**, chosen from what has to share the
   page with it and from the artwork's own pixel width, not run out to the full
   column by default. Example widths, to adjust for the actual artwork: a wide short render at
   100%, a 1016 px-wide piece of artwork at 58% (beyond ~60% it drops under
   200 dpi), a detail view at 85%, a hero and a branding shot at 92%.
4. **Non-breakable groups are what govern pagination** — a figure with its
   caption, a table with its caption and footnote. Get those right and the page
   breaks mostly take care of themselves.
5. **Block quotes become `note[…]` callouts**; **zebra rows with a repeating
   header** on long tables.

## 5. Writing conventions for the Persian body text

- **Ezafe**: write `ه‌ی` (he + ZWNJ + ye), never `ه` + U+0654 — the Persian face
  renders the hamza form so it reads as `ة`. Markdown sources typically arrive
  in the `هٔ` form; convert on the way in.
- **Numbers you type stay as typed.** Auto-numbering is off, so section, table
  and figure numbers are literal Persian digits in the source and are
  cross-referenced from prose by the same literal text.
- Wrap compound numbers in `sn[]`, Latin technical tokens in `lt[]`, mixed
  model codes in `nb[]`. These three are the whole bidi discipline.
- Gloss a Persian technical term with its English equivalent in parentheses at
  **first use only** — e.g. «پیچ اسیر پنل (Captive Panel Screw)».
- **Two Typst markup traps when pasting Markdown into a `.typ` file:**
  - `~` is a **non-breaking space**. Every "≈"/"~" in a source silently
    disappears — it compiles clean and drops the character. Escape it as `\~`.
  - `<word>` is a **label**, so something like `<2%` is a syntax error. Escape
    it as `\<`.

## 6. Build and acceptance checks

Run from the repository root:

```sh
typst compile --root typst --font-path typst/fonts typst/report/report.typ "output/report.pdf"
```

Then verify, in this order:

1. **Render pages to PNG and look at them.** Compiling clean proves nothing
   about layout or bidi.
2. **Check the cover and the contents page are in Dubai**, not the engine's
   default face — the single most common regression, caused by a `set text`
   placed after `title-page`.
3. **Read a compound section number at 400 dpi** and confirm the chapter digit
   is on the right. Do not trust it at screen resolution: ۱ is a plain vertical
   stroke and ۲ is a hook, and they are easy to mistake for one another.
4. **Diff `pdftotext` output against the source as a character multiset.** Compare the intended report text, excluding Typst markup, with extracted
   text; account for generated labels and font/text-extraction limitations. Do this after any bulk
   conversion, because of the `~` trap above. A word-level or line-level diff
   produces false positives — table cell reading order differs — so a
   character comparison is only a diagnostic alongside visual inspection.
5. **Confirm the table of contents still fits on one page.**
