// =============================================================================
// karun.typ — Karun report template (Typst port of karun.sty + titlepage.tex)
//
// Bilingual: English (LTR) and Persian (RTL). Usage in a report file:
//
//   #import "karun.typ": *
//   #import "metadata.typ": meta
//   #show: karun-report.with(lang: "en", meta: meta)
//   #title-page(meta, lang: "en")
//   #contents-page(lang: "en")
//   = First section ...
//
// Requires the Dubai font installed (XeLaTeX template used \setmainfont{Dubai}).
// =============================================================================

// -----------------------------------------------------------------------------
// Colors (from karun.sty \definecolor blocks)
// -----------------------------------------------------------------------------
#let karun-blue = rgb(0, 50, 100)
#let confidential-green = rgb(0, 128, 0)
#let confidential-orange = rgb(255, 165, 0)
#let confidential-red = rgb(255, 0, 0)
#let access-gray = rgb(180, 180, 180)
#let access-blue = rgb(0, 102, 153)
#let access-green = rgb(0, 128, 0)
#let access-strike = rgb(120, 120, 120)
#let bg-curve-color = rgb(230, 242, 255)

// -----------------------------------------------------------------------------
// Per-language helpers
// -----------------------------------------------------------------------------
#let logo-for(lang) = if lang == "en" { "brand/karun-en.png" } else { "brand/karun-fa.png" }
#let is-en(lang) = lang == "en"

// Persian (Extended Arabic-Indic) digits for AUTO-GENERATED numbers only
// (heading numbers, figure/table numbers, page numbers, footnotes). Content the
// author types — technical codes, standards, quantities — is left untouched.
#let _fa-digits = ("۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹")
#let to-fa-digits(s) = {
  let out = ""
  for c in str(s).clusters() {
    let i = "0123456789".position(c)
    out += if i == none { c } else { _fa-digits.at(i) }
  }
  out
}
// Language-aware numbering patterns: Latin for English, Persian for Persian.
#let heading-numbering(lang) = if is-en(lang) { "1.1" } else {
  (..n) => n.pos().map(to-fa-digits).join(".")
}
#let counter-numbering(lang) = if is-en(lang) { "1" } else {
  (..n) => to-fa-digits(n.pos().first())
}

// Page-cohesion helpers for report authors. Use `keep-with-next` around a short
// introduction, `keep-together` around a compact group, and `long-table` around
// a table figure that must be allowed to span pages.
#let keep-with-next(body) = block(sticky: true, body)
#let keep-together(body) = block(breakable: false, body)
#let long-table(body) = {
  show figure.where(kind: table): set block(breakable: true)
  body
}

// Metadata table labels per language.
#let meta-labels(lang) = if lang == "en" {
  (
    title: "Document Title:",
    employer: "Prepared for:",
    producer: "Prepared by:",
    access: "Access Level:",
    confidentiality: "Confidentiality:",
    id: "Document ID:",
    date: "Date:",
  )
} else {
  (
    title: "عنوان سند:",
    employer: "تهیه‌شده برای:",
    producer: "تهیه‌کننده:",
    access: "سطح دسترسی:",
    confidentiality: "سطح محرمانگی:",
    id: "شناسه سند:",
    date: "تاریخ تهیه:",
  )
}

// -----------------------------------------------------------------------------
// Access Level / Confidentiality toggles (strike-through inactive options)
//   access_level:   1 = Internal,  2 = External,     3 = Public
//   confidentiality:1 = Normal,    2 = Confidential, 3 = Top Secret
// -----------------------------------------------------------------------------
#let active-opt(color, body) = text(weight: "bold", fill: color)[#body]
#let inactive-opt(body) = text(fill: access-strike)[#strike[#body]]

#let toggle(active, labels, colors) = {
  let parts = ()
  for i in range(labels.len()) {
    if i + 1 == active {
      parts.push(active-opt(colors.at(i), labels.at(i)))
    } else {
      parts.push(inactive-opt(labels.at(i)))
    }
  }
  parts.join([ \/ ])
}

#let access-level(active, lang: "en") = {
  let labels = if lang == "en" { ("Internal", "External", "Public") } else {
    ("درون سازمانی", "برون سازمانی", "عمومی")
  }
  toggle(active, labels, (access-gray, access-blue, access-green))
}

#let confidentiality-level(active, lang: "en") = {
  let labels = if lang == "en" { ("Normal", "Confidential", "Top Secret") } else {
    ("عادی", "محرمانه", "خیلی محرمانه")
  }
  toggle(active, labels, (confidential-green, confidential-orange, confidential-red))
}

// -----------------------------------------------------------------------------
// Metadata table (booktabs-style: thick top/bottom rules, thin brand-blue rules)
// -----------------------------------------------------------------------------
#let meta-table(meta, lang: "en") = {
  let L = meta-labels(lang)
  let row = (label, value) => (
    text(weight: "bold")[#label], value,
  )
  set text(size: if is-en(lang) { 10pt } else { 11pt })
  table(
    columns: (auto, 1fr),
    stroke: none,
    inset: (x: 6pt, y: 7pt),
    align: (if is-en(lang) { left } else { right }) + horizon,

    table.hline(stroke: 1.2pt + karun-blue),
    ..row(L.title, text(weight: "bold")[#meta.summary_title]),
    table.hline(stroke: 0.4pt + karun-blue),
    ..row(L.employer, meta.employer),
    table.hline(stroke: 0.4pt + karun-blue),
    ..row(L.producer, meta.producer),
    table.hline(stroke: 0.4pt + karun-blue),
    ..row(L.access, access-level(meta.access_level, lang: lang)),
    table.hline(stroke: 0.4pt + karun-blue),
    ..row(L.confidentiality, confidentiality-level(meta.confidentiality, lang: lang)),
    table.hline(stroke: 0.4pt + karun-blue),
    ..row(L.id, meta.doc_id),
    table.hline(stroke: 0.4pt + karun-blue),
    ..row(L.date, meta.date),
    table.hline(stroke: 1.2pt + karun-blue),
  )
}

// -----------------------------------------------------------------------------
// Title page (Typst port of titlepage.tex) — full-bleed, own layout.
// -----------------------------------------------------------------------------
// `agent`: if set to an agent name (string), an "AGENT-GENERATED" stamp is
// placed on the cover with that name as its sub-line. Leave `none` for a
// human-authored report. Backward compatible: omitting it changes nothing.
#let title-page(meta, lang: "en", agent: none) = {
  let english = is-en(lang)
  let logo = logo-for(lang)
  let h-edge = if english { left } else { right }
  let h-sign = if english { 1 } else { -1 }

  page(
    margin: 0pt,
    header: none,
    footer: none,
    numbering: none,
    background: image("brand/bg.jpeg", width: 100%, height: 100%),
  )[
    // Top logo (4 cm), 1 cm inset, opposite the binding edge.
    #place(top + (if english { right } else { left }),
      dx: if english { -1cm } else { 1cm }, dy: 1cm,
      image(logo, width: 4cm))

    // Title + subtitle.
    #place(top + h-edge, dx: h-sign * 2cm, dy: 4.8cm,
      block(width: 13cm)[
        #set align(if english { left } else { right })
        #set par(leading: 0.4em, justify: false)
        #text(size: 25pt, weight: "bold")[#meta.title]
        #v(0.35cm, weak: false)
        #text(size: 15pt, fill: gray)[#meta.subtitle]
      ])

    // Metadata table.
    #place(top + h-edge, dx: h-sign * 2.5cm, dy: 8.8cm,
      block(width: 16cm)[#meta-table(meta, lang: lang)])

    // Footer logo (bottom-left), 1 cm inset. Matches the report language
    // (Persian logo on Persian covers, English on English) for consistent
    // branding. The disclaimer text beside it stays English by design.
    #place(bottom + left, dx: 1cm, dy: -1cm, image(logo, width: 2.5cm))

    // Disclaimer (LTR), to the right of the footer logo.
    #place(bottom + left, dx: 4cm, dy: -1cm,
      block(width: 10cm)[
        #set text(size: 7pt, lang: "en", dir: ltr)
        #set par(justify: false)
        This document is prepared by the Karun team for the intended recipients
        mentioned herein. Any reuse or redistribution to third parties, in any
        form, is prohibited without prior written consent.
      ])

    // Copyright (bottom-right).
    #place(bottom + right, dx: -1.5cm, dy: -1.5cm,
      text(size: 9pt, lang: "en", dir: ltr)[© #meta.year Karun, Iran])

    // "Agent-generated" stamp (only when an agent name is supplied).
    // Placed opposite the title block (mirrored for RTL) to avoid overlap.
    #if agent != none {
      let stamp-edge = if english { right } else { left }
      let stamp-dx = if english { -1.3cm } else { 1.3cm }
      let stamp-rot = if english { -8deg } else { 8deg }
      place(top + stamp-edge, dx: stamp-dx, dy: 5.1cm,
        rotate(stamp-rot,
          box(
            stroke: 1.5pt + karun-blue,
            radius: 3pt,
            inset: (x: 9pt, y: 5pt),
            fill: white,
          )[
            #set align(center)
            #set text(lang: "en", dir: ltr)
            #text(size: 9pt, weight: "bold", fill: karun-blue, tracking: 2pt)[AGENT-GENERATED]
            #v(-3pt)
            #text(size: 8pt, fill: karun-blue, style: "italic")[#agent]
          ]))
    }
  ]
}

// -----------------------------------------------------------------------------
// Table of contents page (styled like \tableofcontents in karun.sty)
// -----------------------------------------------------------------------------
#let contents-page(lang: "en") = {
  let title = if is-en(lang) { "Contents" } else { "فهرست مطالب" }
  heading(level: 1, numbering: none, outlined: false)[#title]
  outline(title: none, indent: auto, depth: 3)
  pagebreak()
}

// -----------------------------------------------------------------------------
// Running header / footer builders (capture meta + lang).
// -----------------------------------------------------------------------------
#let make-header(meta, lang) = context {
  set text(size: 9pt, fill: black)
  // start/end (not left/right) so the columns mirror correctly in RTL: the date
  // hugs the outer reading-start edge and the title stays centered in both langs.
  grid(
    columns: (1fr, 2fr, 1fr),
    align: (start + bottom, center + bottom, end + bottom),
    [#meta.date], [#meta.summary_title], [],
  )
  v(7pt, weak: false)
  line(length: 100%, stroke: 1pt + karun-blue)
}

#let make-footer(meta, lang) = context {
  let logo = logo-for(lang)
  let cur = counter(page).get().first()
  let total = counter(page).final().first()
  // The cover is an unnumbered page 1, so drop it from BOTH the current number
  // and the total (physical - 1). The last page then reads "n of n", not "n-1 of n".
  let page-text = if is-en(lang) {
    [Page #(cur - 1) of #(total - 1)]
  } else {
    [صفحه #to-fa-digits(cur - 1) از #to-fa-digits(total - 1)]
  }
  line(length: 100%, stroke: 1pt + karun-blue)
  v(2pt, weak: true)
  // start/end (not left/right) so in RTL the page number and logo hug the outer
  // edges instead of colliding in the middle.
  grid(
    columns: (1fr, 1fr),
    align: (start + horizon, end + horizon),
    text(size: 9pt)[#page-text],
    image(logo, height: 0.8cm),
  )
}

// -----------------------------------------------------------------------------
// Main show-rule wrapper (the \usepackage{karun} equivalent).
// -----------------------------------------------------------------------------
#let karun-report(lang: "en", meta: (:), body) = {
  let english = is-en(lang)

  // English uses Dubai at 11pt. Persian uses B Nazanin — the traditional Persian
  // book face — at 12pt (Persian book standard for the Nazanin family is 12–13;
  // it sits small on the em, so it reads a touch smaller than 12pt Dubai). Dubai
  // is kept as a glyph fallback for anything B Nazanin lacks.
  set text(
    font: if english { "Dubai" } else { ("B Nazanin", "Dubai") },
    size: if english { 11pt } else { 12pt },
    lang: lang,
    dir: if english { ltr } else { rtl },
  )
  // NOTE: ی-style spelling (ة → ی, and هٔ/ۀ → ه‌ی) is an EDITORIAL step done in
  // the source text (see the karun-report-typst skill), never a render-time substitution here. A
  // string show rule splits the word into separate text elements and Typst does
  // not reshape across that boundary, so joins break («بررسی» → «بررس‌ی»,
  // «نمونه‌ی» → «نمون‌هی») in both fonts. B Nazanin additionally has no glyph
  // for the combining hamza of هٔ (renders tofu boxes), so wrong forms must
  // simply never reach the engine.
  // Render Latin-script runs (technical codes, standards, units — e.g. ANT02,
  // 6063-T6, ISO 2768, 215 MPa) in Dubai. B Nazanin maps ASCII digits to Persian
  // glyphs and has a weaker Latin, which would corrupt codes like "ANT02-A0000".
  // Auto-generated Persian numbers use Persian codepoints, so they are untouched;
  // the slight size reduction improves the color of mixed Persian paragraphs.
  show regex("[A-Za-z0-9]+"): it => if english { it } else {
    text(font: "Dubai", size: 0.92em, it)
  }
  // Leading is font-specific: B Nazanin has a much taller line-box than Dubai, so
  // the same em value yields looser lines. These values were measured to land both
  // languages on the Persian book standard of ~1.5× line-spacing.
  set par(
    justify: true,
    leading: if english { 0.95em } else { 0.55em },
    spacing: if english { 1.15em } else { 1.5em },
  )

  // Section numbering and Karun-blue heading styling. Spacing follows the common
  // typographic rule (and Persian book-layout convention): the gap ABOVE a
  // heading is ~2× the gap BELOW it, both sized in whole line-units of the body
  // text (~17pt line) so they stay proportional — above ≈ 2 lines, below ≈ 1.3
  // lines. Heading sizes track the Persian standard: main ~18, sub ~14, minor ~12.
  set heading(numbering: heading-numbering(lang))
  show heading: it => {
    set text(fill: karun-blue, weight: "bold")
    block(above: 34pt, below: 22pt, sticky: true, it)
  }
  show heading.where(level: 1): set text(size: 18pt)
  show heading.where(level: 2): set text(size: 14pt)
  show heading.where(level: 3): set text(size: 12pt)

  // Footnote numbers follow the document language too.
  set footnote(numbering: counter-numbering(lang))

  // Figures & tables: caption label bold + Karun-blue, body small italic,
  // centered. Tables are treated like LaTeX table floats — auto-numbered
  // ("Table"/"جدول") with the caption ABOVE; images caption below.
  set figure(numbering: counter-numbering(lang))
  show figure: set block(spacing: 16pt)
  show figure.where(kind: image): set figure(supplement: if english { "Figure" } else { "شکل" })
  show figure.where(kind: table): set figure(supplement: if english { "Table" } else { "جدول" })
  // Ordinary table figures stay intact with their captions. Authors can wrap a
  // genuinely long one in `long-table[...]`; repeatable `table.header` rows then
  // continue automatically on subsequent pages.
  show figure.where(kind: table): set block(breakable: false)
  // Table floats (LaTeX-style): caption ABOVE, plus a branded body style —
  // blue header row and subtle blue-tinted gridlines. Scoped to table figures
  // so the cover's metadata table keeps its own booktabs look.
  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    show table: set text(size: if english { 10pt } else { 10.5pt })
    set table(
      inset: (x: 8pt, y: 6pt),
      stroke: 0.5pt + karun-blue.lighten(70%),
      fill: (_, y) => if y == 0 { karun-blue } else { none },
      align: (if english { left } else { right }) + horizon,
    )
    show table.cell.where(y: 0): set text(weight: "bold", fill: white)
    it
  }
  show figure.caption: it => {
    set align(center)
    set text(size: 9pt)
    box[
      #text(weight: "bold", fill: karun-blue)[#it.supplement #context it.counter.display(it.numbering): ]
      #text(style: "italic")[#it.body]
    ]
  }

  // Table of contents entry styling: level-1 bold Karun-blue, deeper black.
  show outline.entry.where(level: 1): set text(weight: "bold", fill: karun-blue)

  // Page geometry + running header/footer (cover overrides these to none).
  // `numbering` here only feeds the Table of Contents page numbers (the visible
  // running footer is the custom `make-footer` below). Persian digits for fa.
  set page(
    paper: "a4",
    margin: (top: 2.4cm, bottom: 3.0cm, left: 3.1cm, right: 2.5cm),
    header-ascent: 0.8cm,
    footer-descent: 1.2cm,
    numbering: if english { none } else { counter-numbering(lang) },
    header: make-header(meta, lang),
    footer: make-footer(meta, lang),
  )

  body
}
