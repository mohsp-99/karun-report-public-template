# Karun Diagram Toolkit — a "SmartArt" catalog for the Typst report

`karun-diagrams.typ` is a library of **diagram tools** — think PowerPoint
SmartArt, but native to the Karun Typst template, brand-consistent, and driven
by report data. Each tool is a function that turns a small amount of *structured,
grounded* content into a polished figure. No external packages; it compiles
offline exactly like the rest of the template.

> **The one rule that matters: diagrams visualize facts, they never invent them.**
> Every label and number you pass a tool must already appear in the report's
> text or tables. A diagram is a re-presentation of established content — if a
> value isn't in the analysis, it cannot appear in a chart. Pick the tool that
> fits the *shape* of the content in the section you're illustrating.

---

## How to use

Import the toolkit alongside the engine, then wrap each call in `diagram(...)`:

```typ
#import "../template/karun.typ": *
#import "../template/karun-diagrams.typ": *
...
#diagram(
  process-flow([Measure], [Derive], [Score], [Report]),
  caption: [ The four-stage analysis pipeline. ],
)
```

- **Always use `diagram(...)`, not bare `#figure`.** It pins `kind: image` so
  every diagram is numbered "Figure N" in one sequence (a bare figure whose body
  contains code would be mis-labelled "Listing").
- **Every diagram gets a caption** that reads as a sentence and is referenced
  naturally in the prose ("…the four stages are shown in Figure 3.").
- **Keep labels short.** Diagrams carry glanceable labels; the explanation lives
  in the surrounding paragraphs, not inside the boxes.
- The palette (`dg-navy`, `dg-mid`, `dg-ok`, `dg-warn`, `dg-bad`, …) is exported
  if you need to tint a specific element to match the report.

---

## Which tool for which section — the selection guide

Match the **shape of the idea** in the section to a tool. If two fit, prefer the
simpler one.

| The content is essentially…                                   | Use            | Category    |
|---------------------------------------------------------------|----------------|-------------|
| An **ordered sequence** of stages, short labels               | `process-flow` | Process     |
| An ordered procedure where **each step needs a sentence**     | `steps-vertical`| Process    |
| A **repeating loop** with no beginning or end                 | `cycle`        | Cycle       |
| A **one-to-many breakdown** (whole → parts, org, taxonomy)    | `hierarchy`    | Hierarchy   |
| **Two things weighed** against each other (A/B, before/after) | `comparison`   | Relationship|
| Items **classified on two axes** (impact×effort, risk grid)   | `matrix-2x2`   | Matrix      |
| **Layered / foundational** levels (foundation → pinnacle)     | `pyramid`      | Pyramid     |
| A set of **parallel, non-ordered** items (features, principles)| `cards`       | List        |
| **Comparing measured numbers** across a few items             | `bar-chart`    | Data        |
| **One headline value** read against thresholds (a margin/score)| `gauge`       | Data        |
| **Events along a timeline** (schedule, roadmap, history)      | `timeline`     | Data        |
| The **2–5 headline numbers** of an executive summary          | `kpi-row`      | Data        |
| **Pulling one finding/risk/note** out of the flow             | `callout`      | Highlight   |

**Section-fit heuristics** (each visualization suits the section it illustrates):

- *Executive summary* → `kpi-row` for the headline numbers; a single `gauge` for
  the one verdict metric; a `callout` for the bottom line.
- *Methodology / "how we did it"* → `process-flow` (overview) or `steps-vertical`
  (detailed).
- *System / architecture description* → `hierarchy`.
- *Options / trade-off / recommendation* → `comparison`, or `matrix-2x2` when
  ranking several items by two criteria.
- *Results / measurements* → `bar-chart` (several values, esp. against a limit)
  or `gauge` (one value vs zones).
- *Roadmap / plan / schedule* → `timeline`.
- *Design principles / key takeaways* → `cards`, or `pyramid` when the items
  stack on one another.

Don't decorate: if a section is already clear as prose or a table, **don't add a
diagram**. One well-chosen figure per idea beats several.

---

## Tool reference

Each entry: what it's **best for**, when **not** to use it, the signature, and a
minimal call. Args shown as `(k: …)` are dictionaries.

### `process-flow` — Process
**Best for:** a short linear sequence (3–6 stages) in order. **Not for:** loops
(use `cycle`) or steps needing sentences (use `steps-vertical`).
```typ
process-flow([Measure geometry], [Derive limits], [Score axes], [Publish], rtl: false)
```

### `steps-vertical` — Process (detailed)
**Best for:** an ordered procedure where each step carries a short explanation.
**Not for:** more than ~6 steps, or purely labelled stages (`process-flow`).
```typ
steps-vertical(
  (title: "Mine the schematic", body: [Extract MPNs and switching frequencies.]),
  (title: "Measure the board",  body: [Read pad coordinates; compute loop areas.]),
)
```

### `cycle` — Cycle
**Best for:** an iterative loop / lifecycle with no start or end (3–7 nodes).
**Not for:** a one-way sequence (`process-flow`).
```typ
cycle([Measure], [Model], [Mitigate], [Re-test], [Verify], hub: [Design loop])
```

### `hierarchy` — Hierarchy
**Best for:** one root broken into N children, each an optional sub-list (org
chart, system decomposition, taxonomy). **Not for:** deep multi-level trees
(keep to root + one level).
```typ
hierarchy([Control board],
  (title: "Power", items: ([Buck], [Switch node])),
  (title: "Digital", items: ([MCU], [Clock])),
)
```

### `comparison` — Relationship
**Best for:** exactly two things set against each other — Option A vs B, before
vs after, pros vs cons. `accent:` per panel to color them (e.g. `dg-ok` /
`dg-bad`). **Not for:** three or more options (use `cards` or `matrix-2x2`).
```typ
comparison(
  (title: "Current", body: [- Loop 46 mm#super[2]\n- Margin +2.1 dB]),
  (title: "Proposed", body: [- Loop 11 mm#super[2]\n- Margin +8.4 dB], accent: dg-ok),
  divider: "→",
)
```

### `matrix-2x2` — Matrix
**Best for:** classifying items on two axes — risk (likelihood×impact),
prioritization (effort×value), SWOT. **Not for:** a single ranking (`bar-chart`).
```typ
matrix-2x2(
  x-axis: ("Low effort", "High effort"), y-axis: ("Low impact", "High impact"),
  tl-title: "Quick wins", tl: [Add stitching vias.],
  tr-title: "Major",      tr: [Re-spin the stackup.],
  bl-title: "Fill-ins",   bl: [Silkscreen tidy-up.],
  br-title: "Reconsider", br: [Swap the regulator.],
)
```

### `pyramid` — Pyramid
**Best for:** layered / foundational concepts, apex = pinnacle (maturity model,
"foundation → compliance"). Top layers hold the least text. **Not for:** equal,
unordered items (`cards`).
```typ
pyramid(
  (title: "Compliance", body: [Class B]),
  (title: "Filtering",  body: [Input filter]),
  (title: "Layout",     body: [Small loops]),
  (title: "Stackup",    body: [Solid ground]),
)
```

### `cards` — List / grouping
**Best for:** a set of parallel, non-sequential items — features, principles,
takeaways. `columns:` default 3. **Not for:** ordered steps (`process-flow`).
```typ
cards(
  (title: "Solid ground", body: [Uninterrupted reference plane.]),
  (title: "Small loops",  body: [Returns under 12 mm#super[2].]),
  (title: "Filtering",    body: [Common-mode choke + X/Y caps.]),
  columns: 3,
)
```

### `bar-chart` — Data
**Best for:** comparing a few measured numbers; optional dashed `limit` line.
**Not for:** one value (`gauge`) or time series (`timeline`).
```typ
bar-chart(
  (label: "150–500 kHz", value: 8.4),
  (label: "0.5–5 MHz",   value: 6.2),
  (label: "5–30 MHz",    value: 11.7),
  unit: " dB", limit: 3,
)
```

### `gauge` — Data
**Best for:** one headline value read against colored zones (a margin, a score,
% complete, pass/fail). `bands:` are `(upper, color)` pairs covering min→max.
**Not for:** several values (`bar-chart`).
```typ
gauge(6.2, min: -6, max: 18, unit: " dB", label: "Worst-case margin", verdict: "PASS",
  bands: ((0, dg-bad.lighten(35%)), (6, dg-warn.lighten(25%)), (18, dg-ok.lighten(20%))))
```

### `timeline` — Data
**Best for:** dated milestones / a schedule / a roadmap (≤6 events, short titles).
**Not for:** an unordered process (`process-flow`).
```typ
timeline(
  (date: "Wk 1", title: "Schematic review"),
  (date: "Wk 3", title: "Fixes applied"),
  (date: "Wk 5", title: "Sign-off"),
)
```

### `kpi-row` — Data
**Best for:** the 2–5 numbers that headline an executive summary. `color:` and
`sub:` optional per tile. **Not for:** many series (`bar-chart`).
```typ
kpi-row(
  (value: "Class B", label: "Predicted CISPR 32", sub: "residential", color: dg-ok),
  (value: "+6.2 dB", label: "Worst-case margin"),
  (value: "9 / 9",   label: "Axes scored"),
)
```

### `callout` — Highlight
**Best for:** lifting one finding, risk, or note out of the flow. `kind:` is
`info | success | caution | critical | note`; it sets the color and default
title. Not a figure — place it inline (no `diagram(...)` wrapper).
```typ
#callout([The switching-node loop is the dominant radiator; treat it first.],
  kind: "caution", title: "Priority")
```

---

## Notes

- **Sizing.** Diagrams span the text width by default. Fixed-canvas tools take a
  size override: `cycle(diameter: 5.5cm)`, `matrix-2x2(size: 7cm)`,
  `pyramid(width: 8cm, layer-height: 1.1cm)`.
- **RTL / Persian.** Text bodies align to the reading start automatically. Pass
  `rtl: true` to `process-flow` to reverse the arrows; on an RTL page horizontal
  layouts mirror.
- **Colors.** Defaults are the Karun blue ramp. Override with the exported
  palette (`dg-ok`/`dg-warn`/`dg-bad` for status, `dg-mid` etc. for tints) — but
  keep semantic use consistent (green = pass, red = fail).
- **Living examples.** `typst/examples/diagram-gallery.typ` renders every tool with
  sample data. Build it from `typst/examples/`:
  `typst compile --root .. --font-path ../fonts diagram-gallery.typ "../build/Diagram Gallery.pdf"`.
