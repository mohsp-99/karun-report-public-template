// =============================================================================
// report.typ — EDIT THIS: your report content (the Typst port of main-article.tex).
//
// 1. Fill in metadata.typ.
// 2. Write your content below using plain Typst markup (see the cheatsheet).
// 3. Build from the repository root; output goes into typst/build/.
//    The build script supplies the bundled font path:
//      python scripts/build.py
//      typst watch --root typst --font-path typst/fonts typst/report/report.typ "typst/build/My Report.pdf"   (live preview)
//
// Set lang to "en" (left-to-right) or "fa" (Persian, right-to-left).
//
// Markup cheatsheet:
//   = Section          -> numbered level-1 heading (Karun blue)
//   == Subsection      -> numbered level-2 heading
//   *bold*  _italic_  `code`
//   - item             -> bullet list
//   "quotes" --- dash  -> become curly quotes / em-dash automatically
//   #figure(image("figures/x.png", width: 100%), caption: [ ... ])  -> caption below
//   #figure(table(columns: 2, table.header([A], [B]), ...),
//     caption: [ ... ])                                           -> table, caption ABOVE
//   #heading(level: 1, numbering: none)[Title]  -> unnumbered, still in the TOC
//   #keep-with-next[Intro.]                  -> keep intro with the next item
//   #keep-together[Short prose + table]      -> keep a compact group on one page
//   #long-table[#figure(table(...))]         -> allow a genuine long table to split
// =============================================================================

#import "../template/karun.typ": *
#import "metadata.typ": meta

#show: karun-report.with(lang: "en", meta: meta)

// --- Title page + table of contents (leave these as-is) ---------------------
#title-page(meta, lang: "en")
#contents-page(lang: "en")

// ===========================================================================
// YOUR CONTENT STARTS HERE — replace everything below.
// ===========================================================================

#heading(level: 1, numbering: none)[Executive Summary]

Replace this paragraph with your executive summary. You can use *bold* and
_italic_ text, "smart quotes", and em-dashes --- like this --- naturally.

= First Section

Write the first section here. Multiple paragraphs are separated by a blank
line, exactly like this one.

== A Subsection

A subsection with a bullet list:

- First point, with a *bold* lead-in.
- Second point, mentioning a `code` term.
- Third point.

// Example figure (uncomment and point at an image in figures/):
// #figure(
//   image("figures/your-figure.png", width: 100%),
//   caption: [ Your caption. Figures are auto-numbered and listed nowhere else. ],
// )

// Example table (use table.header so a long table can repeat its header):
// #figure(
//   table(
//     columns: (1fr, 2fr),
//     table.header([Item], [Finding]),
//     [A], [First finding],
//     [B], [Second finding],
//   ),
//   caption: [ Example findings. ],
// )
