// =============================================================================
// diagram-gallery.typ — a branded showcase of every karun-diagrams tool.
// Doubles as a compile test and as living documentation of the catalog.
//
// Build from inside typst/examples/:
//   typst compile --root .. --font-path ../fonts diagram-gallery.typ "../build/Diagram Gallery.pdf"
// =============================================================================

#import "../template/karun.typ": *
#import "../template/karun-diagrams.typ": *

// Self-contained metadata so the gallery is a standalone showcase (it does not
// depend on the template's placeholder metadata.typ).
#let meta = (
  title: "Karun Diagram Toolkit",
  subtitle: "A SmartArt-style visualization catalog for the Typst report template",
  summary_title: "Diagram Toolkit — Catalog & Gallery",
  employer: "Karun Report Template",
  producer: "karun-diagrams.typ",
  access_level: 3,
  confidentiality: 1,
  doc_id: "KARUN-DIAGRAMS-GALLERY",
  date: "2026/07/12",
  year: 2026,
)

#show: karun-report.with(lang: "en", meta: meta)

#title-page(meta, lang: "en", agent: "report-writer")
#contents-page(lang: "en")

#heading(level: 1, numbering: none)[Diagram Catalog]

This gallery shows each diagram *tool* with the kind of content it visualizes
best. Every tool is native Typst, brand-consistent, and driven by short,
report-grounded labels and numbers.

// --- KPI row (executive headline metrics) -----------------------------------
= Headline metrics — #raw("kpi-row")

#diagram(
  kpi-row(
    (value: "Class B", label: "Predicted CISPR 32", sub: "residential-grade", color: dg-ok),
    (value: "+6.2 dB", label: "Worst-case margin", sub: "150 kHz–30 MHz"),
    (value: "9 / 9", label: "Axes scored", sub: "all measured"),
    (value: "12", label: "Fixes proposed", sub: "3 critical", color: dg-warn),
  ),
  caption: [ Headline metrics for the executive summary. ],
)

// --- Process flow -----------------------------------------------------------
= Linear process — #raw("process-flow")

#diagram(
  process-flow(
    [Measure geometry], [Derive limits], [Score 9 axes], [Predict class], [Publish PDF],
  ),
  caption: [ The five-stage EMC analysis pipeline, in order. ],
)

// --- Vertical steps ---------------------------------------------------------
= Detailed procedure — #raw("steps-vertical")

#diagram(
  steps-vertical(
    (title: "Mine the schematic", body: [Extract MPNs and switching frequencies from the `.SchDoc` files.]),
    (title: "Measure the board", body: [Read pad coordinates; compute loop areas and clearances directly.]),
    (title: "Derive the limits", body: [Run the physics engine for fully-worked, falsifiable results.]),
    (title: "Score and classify", body: [Rate nine axes and state the predicted CISPR class with its margin.]),
  ),
  caption: [ Each step carries a full explanation. ],
)

// --- Cycle ------------------------------------------------------------------
= Iterative loop — #raw("cycle")

#diagram(
  cycle([Measure], [Model], [Mitigate], [Re-test], [Verify], hub: [EMC\ loop]),
  caption: [ The continuous design-for-EMC loop. ],
)

// --- Hierarchy --------------------------------------------------------------
= Breakdown — #raw("hierarchy")

#diagram(
  hierarchy([PDU control board],
    (title: "Power stage", items: ([Buck converter], [Switching node], [Bulk caps])),
    (title: "Digital", items: ([MCU], [Clock tree], [Debug])),
    (title: "I/O", items: ([RS-485], [Relays], [Sense])),
  ),
  caption: [ The board decomposed into subsystems. ],
)

// --- Comparison -------------------------------------------------------------
= Two options set against each other — #raw("comparison")

#diagram(
  comparison(
    (title: "Current layout", body: [
      - Switching loop area 46 mm#super[2]
      - No local ground stitch
      - Margin +2.1 dB
    ]),
    (title: "Proposed layout", body: [
      - Loop area 11 mm#super[2]
      - Stitching vias added
      - Margin +8.4 dB
    ], accent: dg-ok),
    divider: "→",
  ),
  caption: [ Before and after the layout change. ],
)

// --- Matrix 2x2 -------------------------------------------------------------
= Two-axis classification — #raw("matrix-2x2")

#diagram(
  matrix-2x2(
    x-axis: ("Low effort", "High effort"),
    y-axis: ("Low impact", "High impact"),
    tl-title: "Quick wins", tl: [Add stitching vias; shorten the switch node.],
    tr-title: "Major projects", tr: [Re-spin the stackup to 4 layers.],
    bl-title: "Fill-ins", bl: [Silkscreen tidy-up.],
    br-title: "Reconsider", br: [Swap the regulator family.],
  ),
  caption: [ Fixes plotted by effort and impact. ],
)

// --- Pyramid ----------------------------------------------------------------
= Layered foundation — #raw("pyramid")

#diagram(
  pyramid(
    (title: "Compliance", body: [CISPR 32 Class B]),
    (title: "Filtering", body: [Input filter + local decoupling]),
    (title: "Layout", body: [Small loops, short returns]),
    (title: "Stackup", body: [Solid ground reference plane]),
  ),
  caption: [ The EMC design stack, foundation to compliance. ],
)

// --- Cards ------------------------------------------------------------------
= Parallel items — #raw("cards")

#diagram(
  cards(
    (title: "Solid ground plane", body: [An uninterrupted reference under the switcher.]),
    (title: "Small current loops", body: [Bulk cap returns kept under 12 mm#super[2].]),
    (title: "Input filtering", body: [Common-mode choke plus X/Y capacitors.]),
    columns: 3,
  ),
  caption: [ Three parallel design principles. ],
)

// --- Bar chart --------------------------------------------------------------
= Compare measured values — #raw("bar-chart")

#diagram(
  bar-chart(
    (label: "150–500 kHz", value: 8.4),
    (label: "0.5–5 MHz", value: 6.2),
    (label: "5–30 MHz", value: 11.7),
    unit: " dB", limit: 3,
  ),
  caption: [ Emission margin per band against the 3 dB engineering limit. ],
)

// --- Gauge ------------------------------------------------------------------
= Single value vs thresholds — #raw("gauge")

#diagram(
  gauge(6.2, min: -6, max: 18, unit: " dB",
    label: "Worst-case emission margin",
    verdict: "PASS",
    bands: ((0, dg-bad.lighten(35%)), (6, dg-warn.lighten(25%)), (18, dg-ok.lighten(20%)))),
  caption: [ The single headline margin, read against fail / marginal / pass zones. ],
)

// --- Timeline ---------------------------------------------------------------
= Events over time — #raw("timeline")

#diagram(
  timeline(
    (date: "Wk 1", title: "Schematic review"),
    (date: "Wk 2", title: "Layout measured"),
    (date: "Wk 3", title: "Fixes applied"),
    (date: "Wk 4", title: "Pre-compliance scan"),
    (date: "Wk 5", title: "Sign-off"),
  ),
  caption: [ The compliance schedule. ],
)

// --- Callouts ---------------------------------------------------------------
= Highlight a finding — #raw("callout")

#callout([The 5–30 MHz band clears the limit by 11.7 dB — the strongest result.],
  kind: "success", title: "Best result")

#v(6pt)

#callout([The switching-node loop is the dominant radiator; treat it first.],
  kind: "caution")

#v(6pt)

#callout([Without the input filter, conducted emissions exceed the Class B limit.],
  kind: "critical", title: "Blocking issue")
