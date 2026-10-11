// =============================================================================
// karun-fa-style.typ — the shared Persian companion library for the Karun
// template (the hand-numbered Persian house style).
//
// Sits ON TOP of karun.typ; the engine (palette, cover, running header/footer,
// TOC machinery, to-fa-digits, the Latin-in-Dubai rule) is untouched. For
// hand-numbered Persian (RTL) reports whose section numbers live in the heading
// text itself. Import it AFTER the cover and contents pages:
//
//   #import "karun.typ": *
//   #show: karun-report.with(lang: "fa", meta: meta)
//   #set text(font: "Dubai")          // BEFORE title-page, or the cover and the
//   #title-page(meta, lang: "fa")     // contents stay in B Nazanin
//   #contents-page(lang: "fa")
//   #import "karun-fa-style.typ": *
//   #show: fa-refine
//
// docs/persian-style.md documents the full setup block, the per-report helpers that stay
// content-tuned (fig, captions, price-table, nb, lt, ...), the layout rules and
// the writing conventions that go with this library.
// =============================================================================

#import "karun.typ": karun-blue, to-fa-digits
#import "karun-diagrams.typ": dg-seq, dg-tri, dg-mid, dg-pale, dg-line, dg-ink

// -----------------------------------------------------------------------------
// fa-refine — the one document-wide show rule
// -----------------------------------------------------------------------------
#let fa-refine(body) = {
  // These reports carry their own section numbers in the heading text and
  // cross-reference them in prose, so auto-numbering is off.
  set heading(numbering: none)
  // Latin runs sit visually larger than the Persian face at the same point
  // size; render them a touch smaller so the text colour stays even.
  show regex("[A-Za-z0-9]+"): set text(font: "Dubai", size: 0.9em)
  // No heading stranded at the foot of a page.
  show heading: set block(sticky: true)
  body
}

// -----------------------------------------------------------------------------
// Table palette and table helpers
// -----------------------------------------------------------------------------
#let table-head-fill = karun-blue.lighten(88%)
#let table-line      = karun-blue.lighten(72%)
#let table-zebra     = rgb(247, 249, 251)

// Cell-alignment functions to pass as `align:`, matching |:---:| columns in
// source Markdown. Typst calls them with (column, row).
#let centred-first(x, y) = if x == 0 { center + horizon } else { right + horizon }
#let centred-but-first(x, y) = if x == 0 { right + horizon } else { center + horizon }

// The branded table: Karun-blue header band, 0.5pt gridlines, 10.5pt body,
// header row bold in Karun blue. The first row is wrapped in `table.header(…)`
// so it REPEATS when the table breaks across pages (pass the cells plainly; a
// caller-supplied `table.header(…)` first argument is passed through as-is).
// Non-breakable by default; `breakable: true` for the ones that cannot fit on
// a page, `zebra: true` to tint even body rows with `table-zebra`.
#let ktable(breakable: false, zebra: false, ..args) = {
  let named = args.named()
  let pos = args.pos()
  let has-header = pos.len() > 0 and type(pos.first()) == content and pos.first().func() == table.header
  let cells = if has-header { pos } else {
    // Wrap the first row: count the columns to know how many cells that is.
    let cols = named.at("columns", default: 1)
    let ncols = if type(cols) == array { cols.len() } else if type(cols) == int { cols } else { 1 }
    let split = calc.min(ncols, pos.len())
    (table.header(repeat: true, ..pos.slice(0, split)),) + pos.slice(split)
  }
  block(breakable: breakable, width: 100%)[
    #set text(size: 10.5pt)
    #set table(
      inset: (x: 8pt, y: 6pt),
      stroke: 0.5pt + table-line,
      align: right + horizon,
      fill: (_, y) => if y == 0 { table-head-fill } else if zebra and calc.even(y) { table-zebra } else { none },
    )
    #show table.cell.where(y: 0): set text(weight: "bold", fill: karun-blue)
    #table(..named, ..cells)
  ]
}

// The same look for a key/value table with no header row: no header band, no
// `table.header`.
#let ptable(breakable: false, ..args) = block(breakable: breakable, width: 100%)[
  #set text(size: 10.5pt)
  #set table(
    inset: (x: 8pt, y: 6pt),
    stroke: 0.5pt + table-line,
    align: right + horizon,
  )
  #table(..args)
]

// -----------------------------------------------------------------------------
// Prose helpers
// -----------------------------------------------------------------------------

// Block quote / callout. The accent border sits on the RIGHT edge — the RTL
// reading edge, mirroring the left-edge rule of an LTR quote.
#let note(body) = block(
  width: 100%, breakable: false,
  fill: karun-blue.lighten(94%),
  stroke: (right: 3pt + karun-blue),
  radius: 3pt,
  inset: (x: 11pt, y: 9pt),
  body,
)

// Pins an introductory paragraph to the table or figure that follows it.
#let lead(body) = block(sticky: true, body)

// An inline code span drawn as a tinted box. Use this INSTEAD of Typst's `raw`:
// the fallback monospace font is not bundled and cannot shape Arabic script, so
// a Persian identifier in `raw` comes out as disconnected letters.
#let code(body) = box(
  fill: karun-blue.lighten(93%),
  radius: 2pt,
  inset: (x: 4pt),
  outset: (y: 3pt),
  body,
)

// An 8pt unticked checkbox in Karun blue.
#let todo = box(
  width: 8pt, height: 8pt,
  stroke: 1pt + karun-blue,
  radius: 1.5pt,
  baseline: 0.5pt,
)

// `#show: fa-enum` makes `+` lists number in Persian digits.
#let fa-enum(body) = {
  set enum(numbering: n => to-fa-digits(n) + ".")
  body
}

// Wraps a diagram as `figure(…, kind: image)` so it is numbered «شکل N» (the
// engine's Persian supplement) rather than "Figure N".
#let fa-diagram(body, caption: none) = figure(body, caption: caption, kind: image)

// -----------------------------------------------------------------------------
// fa-flow / fa-chain — Persian variants of the karun-diagrams
// process-flow / steps-vertical tools: the step counter reads «گام ۱», text
// hugs the RTL reading edge, and `per-row` splits a long sequence over several
// rows with the colour ramp and numbering running continuously across them.
// -----------------------------------------------------------------------------
#let fa-flow(..steps, per-row: none) = {
  let items = steps.pos()
  let n = items.len()
  if n == 0 { return [] }
  let chunk = if per-row == none { n } else { calc.max(1, per-row) }
  // The connector points along the reading direction — leftward.
  let arrow = box(inset: (x: 3pt), align(horizon, dg-tri(dg-mid, rtl: true)))
  let step-box(i) = box(
    width: 100%, fill: dg-seq(i, n), radius: 8pt, inset: (x: 9pt, y: 9pt),
    align(start + horizon, {
      text(fill: white.transparentize(25%), weight: "bold", size: 7.5pt)[گام #to-fa-digits(i + 1)]
      v(2pt, weak: true)
      set text(fill: white, size: 9.5pt, weight: "medium")
      items.at(i)
    }),
  )
  let rows = ()
  let lo = 0
  while lo < n {
    let hi = calc.min(lo + chunk, n)
    let cells = ()
    let cols = ()
    for j in range(lo, hi) {
      cells.push(step-box(j))
      cols.push(1fr)
      if j < hi - 1 { cells.push(arrow); cols.push(auto) }
    }
    // Pad a short final row so its steps keep the same width as the rows above.
    for _ in range(hi - lo, chunk) {
      cells.push(hide(arrow)); cols.push(auto)
      cells.push([]); cols.push(1fr)
    }
    // In an RTL document the grid lays its first column on the right, so the
    // reading order comes out right-to-left with no extra work here.
    rows.push(grid(columns: cols, align: horizon, ..cells))
    lo = hi
  }
  block(width: 100%, stack(dir: ttb, spacing: 8pt, ..rows))
}

#let fa-chain(..steps) = {
  let items = steps.pos()
  let n = items.len()
  if n == 0 { return [] }
  let rows = ()
  for i in range(n) {
    let it = items.at(i)
    let is-dict = type(it) == dictionary
    let title = if is-dict { it.at("title", default: "") } else { it }
    let body = if is-dict { it.at("body", default: none) } else { none }
    rows.push(box(
      width: 100%, radius: 8pt, fill: dg-pale, stroke: 0.75pt + dg-line,
      inset: 0pt, clip: true,
      grid(
        // First column lands on the right in RTL — the number band leads.
        columns: (1.15cm, 1fr),
        grid.cell(fill: dg-seq(i, n), inset: (x: 4pt, y: 8pt), align: center + horizon, {
          text(fill: white.transparentize(25%), weight: "bold", size: 7.5pt)[گام]
          v(1pt, weak: true)
          text(fill: white, weight: "bold", size: 14pt)[#to-fa-digits(i + 1)]
        }),
        grid.cell(inset: (x: 12pt, y: 9pt), align: start + horizon, {
          text(weight: "bold", size: 10.5pt, fill: karun-blue)[#title]
          if body != none {
            v(2pt, weak: true)
            set text(fill: dg-ink, size: 9.5pt)
            body
          }
        }),
      ),
    ))
  }
  block(width: 100%, stack(dir: ttb, spacing: 8pt, ..rows))
}

// -----------------------------------------------------------------------------
// sn — compound section numbers (the important fix; do not simplify)
//
// A hand-written compound number such as «۸-۲.» renders WRONG in every naive
// form:
//   - Persian digits U+06F0–06F9 are bidi class EN, so «۸-۲» resolves to a
//     single left-to-right number run and lays the chapter number out on the
//     LEFT — the reverse of what is wanted.
//   - The trailing full stop is not between two digits, so it falls back to
//     the paragraph direction and is reordered to the FRONT: «.۸-۲».
//   - Boxing alone fixes only the full stop: it makes the token atomic so the
//     stop stays at the end, but the digits inside are still one number run
//     and still read chapter-left.
// Separating the parts with an RTL mark (U+200F) is what pins the order: each
// digit group becomes its own run, and the runs lay out right to left —
// chapter on the right, section on the left, full stop last. A multi-digit
// group such as «۱۰» keeps its own internal left-to-right order, which is
// correct.
//
// Implemented as a show rule on the SEPARATOR, not on the whole token, so
// every call site stays the literal number. Use `sn[۸-۲.]` for every compound
// number — in headings, in contents entries, and in inline cross-references
// such as «بند ۸-۱». A plain «۸.» needs no wrapper.
// -----------------------------------------------------------------------------
#let sn(body) = box[#show regex("-"): it => "\u{200F}-\u{200F}"
#body]
