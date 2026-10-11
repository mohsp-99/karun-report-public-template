// =============================================================================
// karun-diagrams.typ — Karun "SmartArt" diagram toolkit for the Typst template.
//
// A library of self-contained, brand-consistent diagram *tools*. Each one turns
// a small amount of STRUCTURED, REPORT-GROUNDED data into a polished figure.
// Pure native Typst — NO external packages — so it compiles offline exactly like
// the rest of the template (and travels with each per-report copy).
//
// USAGE — import ALONGSIDE karun.typ, then wrap any tool in a #figure so it is
// auto-numbered and captioned:
//
//   #import "karun.typ": *
//   #import "karun-diagrams.typ": *
//   ...
//   #figure(
//     process-flow([Measure], [Derive], [Score], [Report]),
//     caption: [ The four-stage EMC analysis pipeline. ],
//   )
//
// Each tool = one SmartArt-like shape with a documented "good for …" use. The
// selection guide (which tool for which section) lives in docs/diagrams.md.
//
// GROUNDING RULE: feed these tools ONLY labels and numbers that already appear
// in the report. They are visualizations of established facts — never a source
// of new ones. Keep step labels short; put long prose in the surrounding text.
// =============================================================================

#import "karun.typ": karun-blue, confidential-green, confidential-orange, confidential-red

// -----------------------------------------------------------------------------
// Brand palette — a tint ramp derived from Karun blue, plus a status set.
// -----------------------------------------------------------------------------
#let dg-navy = karun-blue                 // rgb(0, 50, 100) — deepest
#let dg-blue = karun-blue.lighten(16%)
#let dg-mid  = karun-blue.lighten(42%)
#let dg-soft = karun-blue.lighten(70%)
#let dg-pale = karun-blue.lighten(87%)    // page-safe panel background
#let dg-line = karun-blue.lighten(55%)    // hairline / connector rules
#let dg-ink  = rgb(28, 39, 56)            // near-navy slate for text on light fills

#let dg-ok   = confidential-green         // pass / positive
#let dg-warn = rgb(200, 120, 0)           // caution (readable amber; pure orange is too light)
#let dg-bad  = confidential-red.darken(8%) // fail / risk
#let dg-info = karun-blue

// A sequential fill for step i of n (dark → mid as the eye travels along a flow).
#let dg-seq(i, n) = karun-blue.lighten((44 * i / calc.max(n - 1, 1)) * 1%)

// A filled circular badge holding a number or short glyph.
#let dg-badge(body, fill: karun-blue, tcol: white, d: 0.62cm, size: 10pt) = box(
  width: d, height: d, radius: 50%, fill: fill, inset: 0pt,
  align(center + horizon, text(fill: tcol, weight: "bold", size: size)[#body]),
)

// A right/left pointing solid connector triangle.
#let dg-tri(color, w: 8pt, h: 10pt, rtl: false) = if rtl {
  polygon(fill: color, (w, 0pt), (0pt, h/2), (w, h))
} else {
  polygon(fill: color, (0pt, 0pt), (w, h/2), (0pt, h))
}

// -----------------------------------------------------------------------------
// diagram(): the recommended wrapper — use it INSTEAD of #figure for any tool
// below. It pins `kind: image`, so a diagram whose content happens to include
// code/raw is still numbered "Figure N" (not "Listing N") and shares the one
// figure sequence. Caption styling is the template's own.
//   #diagram(process-flow([A], [B], [C]), caption: [ … ])
// -----------------------------------------------------------------------------
#let diagram(body, caption: none) = figure(
  body, caption: caption, kind: image, supplement: [Figure],
)

// =============================================================================
// PROCESS  ▸  process-flow
// Good for: a short LINEAR sequence — a procedure, pipeline or methodology whose
// stages happen in order (e.g. Measure → Derive → Score → Report). 3–6 steps.
// Each arg is a short step label (content). rtl: true reverses the arrows.
// =============================================================================
#let process-flow(..steps, rtl: false) = {
  let items = steps.pos()
  let n = items.len()
  if n == 0 { return [] }

  let arrow = box(inset: (x: 3pt), align(horizon, dg-tri(dg-mid, rtl: rtl)))

  let cells = ()
  let cols = ()
  for i in range(n) {
    let f = dg-seq(i, n)
    cells.push(box(
      width: 100%, fill: f, radius: 8pt, inset: (x: 9pt, y: 9pt),
      align(center + horizon, {
        text(fill: white.transparentize(25%), weight: "bold", size: 7.5pt)[STEP #(i + 1)]
        v(2pt, weak: true)
        set align(center)
        set text(fill: white, size: 9.5pt, weight: "medium")
        items.at(i)
      }),
    ))
    cols.push(1fr)
    if i < n - 1 {
      cells.push(arrow)
      cols.push(auto)
    }
  }
  block(width: 100%, grid(columns: cols, align: horizon, ..cells))
}

// =============================================================================
// PROCESS (detailed)  ▸  steps-vertical
// Good for: an ordered procedure where each step needs a sentence or two — the
// horizontal flow can't hold that much text. Numbered panels, top → bottom.
// Each arg: a (title: "…", body: […]) dict, or a plain label (content).
// =============================================================================
#let steps-vertical(..steps) = {
  let items = steps.pos()
  let n = items.len()
  let rows = ()
  for i in range(n) {
    let it = items.at(i)
    let is-dict = type(it) == dictionary
    let title = if is-dict { it.at("title", default: "") } else { it }
    let body = if is-dict { it.at("body", default: none) } else { none }
    let f = dg-seq(i, n)
    rows.push(box(
      width: 100%, radius: 8pt, fill: dg-pale, stroke: 0.75pt + dg-line,
      inset: 0pt, clip: true,
      grid(
        columns: (1.15cm, 1fr),
        grid.cell(fill: f, inset: 8pt, align: center + horizon,
          text(fill: white, weight: "bold", size: 15pt)[#(i + 1)]),
        grid.cell(inset: (x: 12pt, y: 9pt), align: left + horizon, {
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

// =============================================================================
// CYCLE  ▸  cycle
// Good for: an ITERATIVE / repeating process with no start or end — a feedback
// loop, lifecycle, or continuous-improvement cycle. 3–7 nodes on a ring.
// Each arg: a short node label (content). hub: optional center label.
// =============================================================================
#let cycle(..steps, hub: none, diameter: 6.4cm) = {
  let items = steps.pos()
  let n = items.len()
  if n == 0 { return [] }
  let ring-r = diameter / 2 - 1.15cm
  let node-d = 2.1cm

  block(width: 100%, align(center, box(width: diameter, height: diameter, {
    // Ring.
    place(center + horizon, circle(radius: ring-r, fill: none,
      stroke: (paint: dg-soft, thickness: 9pt)))
    // Directional arrowheads at the mid-angles between nodes.
    for i in range(n) {
      let mang = (360deg / n) * (i + 0.5) - 90deg
      place(center + horizon,
        dx: ring-r * calc.cos(mang), dy: ring-r * calc.sin(mang),
        rotate(mang + 90deg, origin: center + horizon,
          polygon(fill: dg-blue, (0pt, 0pt), (13pt, 6pt), (0pt, 12pt))))
    }
    // Optional hub label.
    if hub != none {
      place(center + horizon, box(width: 2.3cm, align(center + horizon,
        text(fill: dg-mid, weight: "bold", size: 9pt)[#hub])))
    }
    // Nodes.
    for i in range(n) {
      let ang = (360deg / n) * i - 90deg
      place(center + horizon,
        dx: ring-r * calc.cos(ang), dy: ring-r * calc.sin(ang),
        box(width: node-d, height: node-d, radius: 50%, fill: dg-seq(i, n),
          stroke: 3pt + white, inset: 5pt,
          align(center + horizon, {
            text(fill: white.transparentize(20%), weight: "bold", size: 8pt)[#(i + 1)]
            v(1pt, weak: true)
            set align(center)
            text(fill: white, size: 8.5pt, weight: "medium")[#items.at(i)]
          })))
    }
  })))
}

// =============================================================================
// HIERARCHY  ▸  hierarchy
// Good for: a one-to-many breakdown — an org chart, a system decomposed into
// subsystems, a taxonomy. One root, N children (each an optional sub-list).
// root: content. Each child arg: a (title: "…", items: (…)) dict or a label.
// =============================================================================
#let hierarchy(root, ..children) = {
  let kids = children.pos()
  let m = kids.len()
  let rail = 1.4pt + dg-line

  let root-box = align(center, box(
    fill: dg-navy, radius: 8pt, inset: (x: 14pt, y: 9pt),
    text(fill: white, weight: "bold", size: 11pt)[#root],
  ))

  if m == 0 { return block(width: 100%, root-box) }

  // Connector band: drop from root, horizontal bus, drops to each child.
  let connector = box(width: 100%, height: 0.75cm, {
    place(top + center, line(start: (0pt, 0pt), end: (0pt, 0.375cm), stroke: rail))
    let x0 = (0.5 / m) * 100%
    let x1 = ((m - 0.5) / m) * 100%
    place(top + left, dx: x0, dy: 0.375cm,
      line(start: (0pt, 0pt), end: (x1 - x0, 0pt), stroke: rail))
    for i in range(m) {
      place(top + left, dx: ((i + 0.5) / m) * 100%, dy: 0.375cm,
        line(start: (0pt, 0pt), end: (0pt, 0.375cm), stroke: rail))
    }
  })

  let cells = ()
  for k in kids {
    let is-dict = type(k) == dictionary
    let title = if is-dict { k.at("title", default: "") } else { k }
    let list = if is-dict { k.at("items", default: ()) } else { () }
    cells.push(box(
      width: 100%, radius: 7pt, fill: dg-pale, stroke: 0.75pt + dg-line,
      inset: (x: 10pt, y: 8pt), align(left + top, {
        text(weight: "bold", fill: karun-blue, size: 9.5pt)[#title]
        if list.len() > 0 {
          v(3pt, weak: true)
          set text(fill: dg-ink, size: 8.5pt)
          for li in list { block(spacing: 3pt, [• #li]) }
        }
      }),
    ))
  }

  block(width: 100%, {
    root-box
    connector
    grid(columns: (1fr,) * m, column-gutter: 8pt, align: left + top, ..cells)
  })
}

// =============================================================================
// RELATIONSHIP  ▸  comparison
// Good for: two things set against each other — Option A vs B, Before vs After,
// Pros vs Cons, current vs proposed. Two headed panels with a divider badge.
// left / right: (title: "…", body: […], accent: <color>) dicts.
// =============================================================================
#let comparison(left, right, divider: "vs") = {
  let panel(p, default-accent) = {
    let title = p.at("title", default: "")
    let body = p.at("body", default: none)
    let acc = p.at("accent", default: default-accent)
    box(
      width: 100%, radius: 8pt, clip: true, stroke: 0.75pt + acc.lighten(45%),
      stack(dir: ttb,
        block(width: 100%, fill: acc, inset: (x: 11pt, y: 7pt),
          text(fill: white, weight: "bold", size: 11pt)[#title]),
        block(width: 100%, fill: acc.lighten(88%), inset: 11pt, {
          set align(start)
          set text(fill: dg-ink, size: 9.5pt)
          body
        })),
    )
  }
  let mid = if divider == none { h(9pt) } else {
    box(inset: (x: 8pt), align(horizon, dg-badge(divider, fill: dg-mid, d: 0.8cm, size: 10pt)))
  }
  block(width: 100%, grid(
    columns: (1fr, auto, 1fr), align: horizon,
    panel(left, dg-navy), mid, panel(right, karun-blue.lighten(30%)),
  ))
}

// =============================================================================
// MATRIX  ▸  matrix-2x2
// Good for: classifying items on TWO axes — risk (likelihood × impact),
// prioritization (effort × value), a positioning or SWOT grid.
// x-axis / y-axis: ("low label", "high label"). tl/tr/bl/br: quadrant content.
// =============================================================================
#let matrix-2x2(
  x-axis: ("Low", "High"),
  y-axis: ("Low", "High"),
  tl: [], tr: [], bl: [], br: [],
  tl-title: none, tr-title: none, bl-title: none, br-title: none,
  colors: (dg-soft, dg-mid.lighten(20%), dg-pale, dg-soft),
  size: 8.4cm,
) = {
  let quad(title, body, fill) = grid.cell(fill: fill, inset: 10pt, align: left + top, {
    if title != none {
      text(weight: "bold", fill: karun-blue, size: 10pt)[#title]
      v(2pt, weak: true)
    }
    set text(fill: dg-ink, size: 8.5pt)
    body
  })

  let square = box(width: size, height: size, radius: 6pt, clip: true,
    stroke: 0.75pt + dg-line,
    grid(
      columns: (1fr, 1fr), rows: (1fr, 1fr), gutter: 2pt, fill: white,
      quad(tl-title, tl, colors.at(0)),
      quad(tr-title, tr, colors.at(1)),
      quad(bl-title, bl, colors.at(2)),
      quad(br-title, br, colors.at(3)),
    ))

  let axcol = dg-mid
  let y-lab = box(height: size, align(horizon, rotate(-90deg, reflow: true,
    text(fill: axcol, weight: "bold", size: 9pt)[#y-axis.at(0) #sym.arrow.r #y-axis.at(1)])))
  let x-lab = align(center,
    text(fill: axcol, weight: "bold", size: 9pt)[#x-axis.at(0) #sym.arrow.r #x-axis.at(1)])

  block(width: 100%, align(center, grid(
    columns: (0.7cm, auto), rows: (auto, 0.6cm), column-gutter: 4pt, row-gutter: 5pt,
    y-lab, square,
    [], x-lab,
  )))
}

// =============================================================================
// PYRAMID  ▸  pyramid
// Good for: layered / foundational concepts — a maturity model, Maslow-style
// hierarchy, "foundation → pinnacle". Apex is the accent (darkest). Top layers
// hold the least text. Each arg: a (title: …, body: …) dict or a label.
// =============================================================================
#let pyramid(..layers, width: 9.5cm, layer-height: 1.35cm) = {
  let items = layers.pos()
  let n = items.len()
  if n == 0 { return [] }
  let W = width
  // Truncated apex: even the top layer keeps `apex` of the half-width so its
  // label has room (a true point clips text). Silhouette is linear top→base.
  let apex = 0.30
  let hw(k) = W / 2 * (apex + (1 - apex) * k / n)
  let rows = ()
  for i in range(n) {
    let it = items.at(i)
    let is-dict = type(it) == dictionary
    let title = if is-dict { it.at("title", default: "") } else { it }
    let body = if is-dict { it.at("body", default: none) } else { none }
    let top-hw = hw(i)
    let bot-hw = hw(i + 1)
    let h = layer-height
    let fill = karun-blue.lighten((52 * i / calc.max(n - 1, 1)) * 1%)
    rows.push(box(width: W, height: h, {
      place(top + left, polygon(fill: fill, stroke: 1.5pt + white,
        (W / 2 - top-hw, 0pt), (W / 2 + top-hw, 0pt),
        (W / 2 + bot-hw, h), (W / 2 - bot-hw, h)))
      place(center + horizon, box(width: top-hw + bot-hw - 8pt, align(center + horizon, {
        set align(center)
        text(fill: white, weight: "bold", size: 9.5pt)[#title]
        if body != none {
          v(1pt, weak: true)
          text(fill: white.transparentize(10%), size: 8pt)[#body]
        }
      })))
    }))
  }
  block(width: 100%, align(center, stack(dir: ttb, spacing: 0pt, ..rows)))
}

// =============================================================================
// LIST / GROUPING  ▸  cards
// Good for: a set of PARALLEL, non-sequential items — features, categories,
// key takeaways, principles. A responsive grid of accent-topped cards.
// Each arg: a (title: "…", body: […]) dict or plain content. columns: default 3.
// =============================================================================
#let cards(..items, columns: 3) = {
  let its = items.pos()
  let cells = ()
  for it in its {
    let is-dict = type(it) == dictionary
    let title = if is-dict { it.at("title", default: "") } else { "" }
    let body = if is-dict { it.at("body", default: none) } else { it }
    cells.push(box(
      width: 100%, radius: 8pt, fill: dg-pale, stroke: 0.75pt + dg-line,
      inset: 0pt, clip: true, {
        block(width: 100%, height: 5pt, fill: karun-blue, above: 0pt, below: 0pt)[]
        pad(x: 11pt, y: 10pt, {
          set align(start)
          if title != "" {
            text(weight: "bold", fill: karun-blue, size: 10.5pt)[#title]
            v(3pt, weak: true)
          }
          set text(fill: dg-ink, size: 9.5pt)
          body
        })
      },
    ))
  }
  block(width: 100%, grid(columns: (1fr,) * columns, gutter: 8pt, align: left + top, ..cells))
}

// =============================================================================
// DATA  ▸  bar-chart  (horizontal, grounded numbers)
// Good for: comparing MEASURED quantities across a few items — margins per band,
// scores per axis, cost per option. Optional dashed `limit` reference line.
// Each arg: a (label: "…", value: <number>, color: <color>) dict.
// =============================================================================
#let bar-chart(..bars, max: auto, unit: "", limit: none, show-values: true) = {
  let bs = bars.pos()
  if bs.len() == 0 { return [] }
  let vals = bs.map(b => b.at("value"))
  let m = if max == auto { calc.max(..vals) } else { max }
  if limit != none { m = calc.max(m, limit) }
  if m <= 0 { m = 1 }

  let rows = ()
  for i in range(bs.len()) {
    let b = bs.at(i)
    let lab = b.at("label", default: "")
    let v = b.at("value")
    let col = b.at("color", default: dg-seq(i, bs.len()))
    let ratio = calc.max(0, calc.min(1, v / m))
    rows.push(grid(
      columns: (3.2cm, 1fr, auto), align: (right + horizon, left + horizon, left + horizon),
      column-gutter: 8pt,
      text(size: 9pt, fill: dg-ink)[#lab],
      box(width: 100%, height: 0.55cm, radius: 3pt, fill: dg-pale, clip: true, {
        place(left + horizon, box(width: ratio * 100%, height: 100%, radius: 3pt, fill: col))
        if limit != none {
          place(left + top, dx: (limit / m) * 100%,
            line(start: (0pt, 0pt), end: (0pt, 100%),
              stroke: (paint: dg-bad, thickness: 1.2pt, dash: "dashed")))
        }
      }),
      if show-values { text(size: 9pt, weight: "bold", fill: karun-blue)[#v#unit] } else { [] },
    ))
  }
  block(width: 100%, {
    if limit != none {
      align(right, text(size: 8pt, fill: dg-bad, style: "italic")[
        #box(width: 12pt, line(length: 100%, stroke: (paint: dg-bad, thickness: 1.2pt, dash: "dashed")))
        limit: #limit#unit
      ])
      v(3pt, weak: true)
    }
    stack(dir: ttb, spacing: 7pt, ..rows)
  })
}

// =============================================================================
// DATA  ▸  gauge  (a single value vs thresholds)
// Good for: ONE headline measured value read against limits — an EMC margin, a
// health score, % complete, a pass/fail band. Colored zones + a needle marker.
// value: number. bands: ((upper, color), …) covering min→max. label: what it is.
// =============================================================================
#let gauge(value, min: 0, max: 100, bands: none, label: none, unit: "", verdict: none) = {
  let span = if max > min { max - min } else { 1 }
  let clamped = calc.max(min, calc.min(max, value))
  let pos = (clamped - min) / span
  let track-h = 0.72cm

  let track = box(width: 100%, height: track-h, radius: 5pt, clip: true, fill: dg-pale, {
    if bands != none {
      let prev = min
      for band in bands {
        let (upper, bcol) = band
        let lo = calc.max(prev, min)
        let hi = calc.min(upper, max)
        if hi > lo {
          place(left + horizon, dx: ((lo - min) / span) * 100%,
            box(width: ((hi - lo) / span) * 100%, height: 100%, fill: bcol))
        }
        prev = upper
      }
    } else {
      place(left + horizon, box(width: pos * 100%, height: 100%, fill: karun-blue))
    }
    // Needle marker.
    place(left + top, dx: pos * 100%,
      line(start: (0pt, -3pt), end: (0pt, track-h + 3pt), stroke: 2.5pt + dg-ink))
    place(left + top, dx: pos * 100% - 4pt, dy: -7pt,
      polygon(fill: dg-ink, (0pt, 0pt), (8pt, 0pt), (4pt, 5pt)))
  })

  block(width: 100%, {
    // Readout line.
    grid(columns: (1fr, auto), align: (left + bottom, right + bottom),
      {
        if label != none { text(size: 9.5pt, fill: dg-mid, weight: "medium")[#label]; linebreak() }
        text(size: 20pt, weight: "bold", fill: karun-blue)[#value#unit]
        if verdict != none {
          h(8pt)
          box(baseline: 4pt, fill: dg-mid.lighten(70%), radius: 3pt, inset: (x: 6pt, y: 2pt),
            text(size: 9pt, weight: "bold", fill: dg-navy)[#verdict])
        }
      },
      [],
    )
    v(6pt, weak: true)
    track
    v(3pt, weak: true)
    grid(columns: (auto, 1fr, auto),
      text(size: 8pt, fill: dg-mid)[#min#unit], [],
      text(size: 8pt, fill: dg-mid)[#max#unit])
  })
}

// =============================================================================
// DATA  ▸  timeline  (horizontal, dated milestones)
// Good for: events over TIME — a project schedule, roadmap, or history. Dots on
// a rail with dates; labels alternate above/below. Keep titles short. ≤6 events.
// Each arg: a (date: "…", title: "…") dict.
// =============================================================================
#let timeline(..events) = {
  let evs = events.pos()
  let n = evs.len()
  if n == 0 { return [] }
  let H = 3.4cm
  let y-mid = H / 2
  let LW = 3cm
  let x-of(i) = if n == 1 { 50% } else { 8% + (i / (n - 1)) * 84% }

  let label-block(e) = box(width: LW, {
    set align(center)
    text(size: 9pt, weight: "bold", fill: karun-blue)[#e.at("date", default: "")]
    if e.at("title", default: none) != none {
      v(1pt, weak: true)
      text(size: 8.5pt, fill: dg-ink)[#e.at("title")]
    }
  })

  block(width: 100%, box(width: 100%, height: H, {
    place(left + horizon, dx: 8%, line(start: (0pt, 0pt), end: (84%, 0pt),
      stroke: 2.5pt + dg-line))
    for i in range(n) {
      let e = evs.at(i)
      let x = x-of(i)
      // Dot.
      place(left + horizon, dx: x - 0.17cm,
        box(width: 0.34cm, height: 0.34cm, radius: 50%, fill: dg-seq(i, n),
          stroke: 3pt + white))
      // Label above (even) / below (odd).
      if calc.rem(i, 2) == 0 {
        place(left + top, dx: x - LW / 2, dy: 0pt,
          align(bottom, box(height: y-mid - 0.5cm, align(bottom, label-block(e)))))
      } else {
        place(left + top, dx: x - LW / 2, dy: y-mid + 0.5cm, label-block(e))
      }
    }
  }))
}

// =============================================================================
// DATA  ▸  kpi-row  (headline stat tiles)
// Good for: the 2–5 numbers that carry an executive summary — a row of big-number
// tiles. Each arg: a (value: "…", label: "…", sub: "…", color: <color>) dict.
// =============================================================================
#let kpi-row(..tiles) = {
  let ts = tiles.pos()
  if ts.len() == 0 { return [] }
  let cells = ()
  for t in ts {
    let value = t.at("value")
    let lab = t.at("label", default: "")
    let sub = t.at("sub", default: none)
    let col = t.at("color", default: karun-blue)
    cells.push(box(
      width: 100%, radius: 8pt, fill: dg-pale, stroke: 0.75pt + dg-line,
      inset: (x: 12pt, y: 11pt), {
        text(size: 22pt, weight: "bold", fill: col)[#value]
        v(2pt, weak: true)
        text(size: 9pt, fill: dg-ink, weight: "medium")[#lab]
        if sub != none {
          v(1pt, weak: true)
          text(size: 8pt, fill: dg-mid)[#sub]
        }
      },
    ))
  }
  block(width: 100%, grid(columns: (1fr,) * ts.len(), gutter: 8pt, align: left + top, ..cells))
}

// =============================================================================
// HIGHLIGHT  ▸  callout
// Good for: pulling ONE finding, risk, or note out of the flow. kind sets the
// color + default label: info | success | caution | critical | note.
// callout([body], kind: "caution", title: "Optional heading")
// =============================================================================
#let callout(body, kind: "info", title: auto) = {
  let cfg = (
    info:     (col: karun-blue, bg: karun-blue.lighten(89%), icon: "i", label: "Note"),
    success:  (col: dg-ok, bg: dg-ok.lighten(86%), icon: sym.checkmark, label: "Pass"),
    caution:  (col: dg-warn, bg: dg-warn.lighten(82%), icon: "!", label: "Caution"),
    critical: (col: dg-bad, bg: dg-bad.lighten(86%), icon: "!", label: "Critical"),
    note:     (col: dg-mid, bg: dg-pale, icon: sym.star.filled, label: "Note"),
  )
  let c = cfg.at(kind, default: cfg.info)
  let ttl = if title == auto { c.label } else { title }
  block(width: 100%, radius: 6pt, fill: c.bg, stroke: (left: 3pt + c.col),
    inset: (x: 12pt, y: 10pt),
    grid(columns: (auto, 1fr), column-gutter: 9pt, align: (top, top),
      dg-badge(c.icon, fill: c.col, d: 0.6cm, size: 10pt),
      {
        set align(start)
        if ttl != none and ttl != "" {
          text(weight: "bold", fill: c.col, size: 10.5pt)[#ttl]
          v(2pt, weak: true)
        }
        set text(fill: dg-ink, size: 9.5pt)
        body
      }))
}
