// =============================================================================
// diagrams.typ — native redraws of the two Mermaid charts in the source
// markdown. Every node and edge label is copied verbatim from the source.
// Coordinates are physical (cm, y grows downward) so routing is exact.
// =============================================================================

#import "@preview/fletcher:0.5.8" as fl
#import "../template/karun.typ": karun-blue

#let c-navy = karun-blue
#let c-blue = karun-blue.lighten(16%)
#let c-line = karun-blue.lighten(25%)
#let c-pale = karun-blue.lighten(88%)
#let c-panel = karun-blue.lighten(95%)
#let c-ink = rgb(28, 39, 56)

// fletcher's physical axes point y upward, so y is negated here.
#let P(x, y) = (x * 1cm, -y * 1cm)
// The canvas resets base direction to LTR; labels need RTL for Persian/Latin order.
#let fa(body) = { set text(dir: rtl); set par(justify: false); body }

// Box node: fixed size, text wrapped and centered.
#let bx(x, y, w, h, body, fill: c-pale, ink: c-ink, stroke: 0.8pt + c-line, size: 8.5pt, weight: "regular") = fl.node(
  P(x, y),
  box(width: (w - 0.3) * 1cm, align(center, fa(text(size: size, fill: ink, weight: weight, body)))),
  width: w * 1cm, height: h * 1cm, fill: fill, stroke: stroke, corner-radius: 4pt, inset: 0pt,
)
#let dark(x, y, w, h, body) = bx(x, y, w, h, body, fill: c-navy, ink: white, stroke: none, weight: "bold")
#let mid(x, y, w, h, body) = bx(x, y, w, h, body, fill: c-blue, ink: white, stroke: none)

// Decision diamond. fletcher circumscribes the diamond around the given box,
// so the box is sized at 1/1.5 of the intended outer width/height.
#let dm(x, y, w, h, body) = fl.node(
  P(x, y),
  box(width: (w * 0.56) * 1cm, align(center, fa(text(size: 8pt, fill: c-ink, weight: "bold", body)))),
  width: w / 1.5 * 1cm, height: h / 1.5 * 1cm, shape: fl.shapes.diamond, fill: c-pale, stroke: 0.8pt + c-line, inset: 0pt,
)

// Background panel for a layer (drawn behind everything).
#let panel(x0, y0, x1, y1) = fl.node(
  P((x0 + x1) / 2, (y0 + y1) / 2), [],
  width: (x1 - x0) * 1cm, height: (y1 - y0) * 1cm,
  fill: c-panel, stroke: (paint: c-line.lighten(40%), thickness: 0.7pt, dash: "dashed"),
  corner-radius: 6pt, layer: -1,
)
#let ptitle(x, y, body) = fl.node(P(x, y), fa(text(size: 8.5pt, weight: "bold", fill: c-navy, body)), stroke: none, inset: 0pt, shape: rect)

// Edge label with a white knock-out so it stays readable over lines.
#let lb(x, y, body) = fl.node(P(x, y), fa(text(size: 7.5pt, fill: c-ink, body)), fill: white, stroke: none, inset: 1.5pt, shape: rect)

// Polyline edges through physical points. `solid` = directive, `dashed` = coordination.
#let ln(..pts, mark: "-|>", dash: none, crossing: false) = fl.edge(
  ..pts.pos().map(p => P(..p)),
  mark,
  stroke: (paint: c-line, thickness: 0.8pt, dash: dash),
  crossing: crossing, crossing-thickness: 4,
  // Endpoints are exact border points; never snap them to (panel) nodes.
  snap-to: (none, none),
)
#let dl(..pts, mark: "-|>", crossing: false) = ln(..pts, mark: mark, dash: "dashed", crossing: crossing)

// -----------------------------------------------------------------------------
// Figure 1 — structure and main relationships
// -----------------------------------------------------------------------------
#let structure-diagram = fl.diagram(
  spacing: 0pt,
  // Layer panels
  panel(0.45, 5.75, 14.65, 8.2),
  panel(0.45, 9.55, 14.65, 13.25),

  // Governance chain
  dark(7.4, 0.45, 3.4, 0.9)[مدیرعامل کارون],
  bx(7.4, 2.15, 6.4, 0.9, weight: "bold")[حامی پروژه و در پروژه منتخب کمیته راهبری],
  dark(7.4, 4.1, 4.2, 1.1)[مدیر پروژه؛ \ #text(weight: "regular", size: 7.5pt)[مرکز هدایت و یکپارچه‌سازی]],
  bx(13.4, 4.1, 2.2, 0.9, fill: white, stroke: 1pt + c-navy, weight: "bold")[کارفرما],

  ln((7.4, 0.9), (7.4, 1.7)),
  lb(8.75, 1.3)[تفویض اختیار],
  ln((7.0, 2.6), (7.0, 3.55)),
  lb(5.75, 3.08)[تصمیم و نظارت],
  dl((7.8, 3.55), (7.8, 2.6)),
  lb(9.4, 3.08)[گزارش و ارجاع تعارض],
  ln((9.5, 4.1), (12.3, 4.1), mark: "<|-|>"),
  lb(10.9, 3.72)[تعهدات و تأییدهای رسمی],

  // PM -> five Pargar domains (bus)
  ln((7.4, 4.65), (7.4, 5.45), mark: "-"),
  ln((1.6, 5.45), (13.2, 5.45), mark: "-"),
  ..(1.6, 4.5, 7.4, 10.3, 13.2).map(x => ln((x, 5.45), (x, 6.1))),

  // Layer 1
  ..(
    (13.2, "P1", "مهندسی"),
    (10.3, "P2", "تأمین"),
    (7.4, "P3", "مدیریت ساخت"),
    (4.5, "P4", "کیفیت"),
    (1.6, "P5", "دانش"),
  ).map(((x, code, name)) => mid(x, 6.6, 2.5, 1.0)[#text(weight: "bold")[#code] #name]),
  ptitle(1.65, 7.65)[#align(center)[لایه اول؛ \ پنج حوزه اصلی پرگار]],

  // PM capacity / service-level agreements (outer corridors)
  dl((5.3, 4.1), (0.2, 4.1), (0.2, 12.35), (3.6, 12.35)),
  lb(2.6, 3.85)[توافق ظرفیت],
  dl((8.8, 4.65), (8.8, 4.98), (14.9, 4.98), (14.9, 12.35), (14.35, 12.35)),
  lb(11.0, 4.74)[توافق سطح خدمت],
  // P5 knowledge feedback to PM
  dl((1.0, 6.1), (1.0, 4.98), (6.0, 4.98), (6.0, 4.65)),
  lb(3.5, 4.74)[جمع‌بندی تجربه‌های معتبر حوزه‌ها],

  // Layer 2 — Karun services
  ptitle(1.75, 10.15)[#align(center)[لایه دوم؛ \ خدمات کارون]],
  bx(6.0, 10.5, 4.8, 1.2)[F1 ساخت، F2 انبار، F3 مونتاژ، F4 لجستیک، F5 بسته‌بندی],
  bx(11.95, 10.5, 4.8, 1.2)[S1 حمل بین‌المللی، S2 بازرگانی خارجی، S3 مالی، S4 منابع انسانی، S5 حقوقی],
  bx(6.0, 12.35, 4.8, 0.9, weight: "bold")[مدیر کارخانه؛ تعهد ظرفیت پنج خدمت],
  bx(11.95, 12.35, 4.8, 0.9, weight: "bold")[مدیران واحدهای پشتیبان؛ تعهد سطح خدمت],
  ln((6.0, 11.9), (6.0, 11.1)),
  lb(7.2, 11.5)[مدیریت سازمانی],
  ln((11.95, 11.9), (11.95, 11.1)),
  lb(13.15, 11.5)[مدیریت سازمانی],

  // Layer 3 — external
  bx(8.7, 14.65, 11.6, 0.9, weight: "bold")[لایه سوم؛ پیمانکاران و تأمین‌کنندگان بیرونی],

  // Domain -> service / external interfaces
  ln((10.6, 7.1), (10.6, 9.9)),
  lb(12.25, 9.3)[سفارش و هماهنگی تجاری],
  ln((9.9, 7.1), (9.9, 8.95), (9.05, 8.95), (9.05, 14.2)),
  lb(10.55, 13.72)[سفارش و تعهد تجاری],
  ln((7.0, 7.1), (7.0, 9.9)),
  lb(5.95, 7.68)[برنامه و \ پیگیری اجرا],
  dl((4.8, 7.1), (4.8, 9.9)),
  lb(5.95, 9.0)[بازرسی و \ تصمیم کیفی],
  dl((4.2, 7.1), (4.2, 8.9), (3.0, 8.9), (3.0, 14.2)),
  lb(1.95, 13.72)[کنترل انطباق],
  dl((7.8, 7.1), (7.8, 9.25), (8.75, 9.25), (8.75, 14.2)),
  lb(7.25, 13.72)[کنترل پیشرفت ساخت],
  // Drawn last so their halos cut cleanly across the lines beneath.
  dl((13.2, 7.1), (13.2, 8.6), (8.15, 8.6), (8.15, 9.9), crossing: true),
  lb(12.0, 8.38)[مدارک معتبر],
)

// -----------------------------------------------------------------------------
// Figure 2 — issue escalation and conflict resolution
// Mirrored for RTL: the side branch sits on the right, outcomes on the left.
// -----------------------------------------------------------------------------
#let W = 14.6
#let m(x) = W - x

#let escalation-diagram = fl.diagram(
  spacing: 0pt,
  bx(m(7.0), 0.4, 5.0, 0.8, weight: "bold")[تشخیص مسئله و ثبت شواهد],
  dm(m(7.0), 1.9, 5.0, 1.5)[خطر فوری یا احتمال مصرف محصول نامنطبق؟],
  bx(m(1.8), 1.9, 3.4, 1.0, fill: rgb(253, 238, 224), stroke: 0.8pt + rgb(200, 120, 0))[توقف یا مهار مجاز و اطلاع فوری],
  bx(m(7.0), 3.55, 4.4, 0.8)[بررسی توسط صاحب حوزه],
  dm(m(7.0), 5.0, 4.8, 1.3)[راه‌حل در اختیار حوزه است؟],
  bx(m(7.0), 6.55, 4.8, 0.8)[مدیر پروژه؛ تحلیل گزینه و اثر],
  dm(m(7.0), 8.0, 4.8, 1.3)[در حدود اختیار مدیر پروژه؟],
  bx(m(7.0), 9.55, 4.8, 0.8)[حامی یا کمیته طبق نوع تصمیم],
  dm(m(7.0), 11.0, 4.8, 1.3)[در اختیار تفویض‌شده؟],
  bx(m(7.0), 12.55, 4.8, 0.8)[مدیرعامل یا صاحب اختیار قانونی شرکت],
  bx(m(12.5), 8.0, 3.4, 7.2, fill: c-navy.lighten(8%), ink: white, stroke: none, weight: "bold", size: 9pt)[اجرا و ثبت نتیجه],
  dark(m(12.5), 13.9, 3.8, 0.9)[کنترل اثربخشی و بستن مسئله],

  ln((m(7.0), 0.8), (m(7.0), 1.15)),
  // B
  ln((m(4.5), 1.9), (m(3.5), 1.9)),
  lb(m(4.0), 1.68)[بله],
  ln((m(7.0), 2.65), (m(7.0), 3.15)),
  lb(m(6.4), 2.9)[خیر],
  ln((m(1.8), 2.4), (m(1.8), 3.55), (m(4.8), 3.55)),
  // E
  ln((m(7.0), 3.95), (m(7.0), 4.35)),
  ln((m(9.4), 5.0), (m(10.8), 5.0)),
  lb(m(10.1), 4.72)[بله],
  ln((m(7.0), 5.65), (m(7.0), 6.15)),
  lb(m(6.4), 5.9)[خیر],
  // H
  ln((m(7.0), 6.95), (m(7.0), 7.35)),
  ln((m(9.4), 8.0), (m(10.8), 8.0)),
  lb(m(10.1), 7.72)[بله],
  ln((m(7.0), 8.65), (m(7.0), 9.15)),
  lb(m(6.4), 8.9)[خیر],
  // J
  ln((m(7.0), 9.95), (m(7.0), 10.35)),
  ln((m(9.4), 11.0), (m(10.8), 11.0)),
  lb(m(10.1), 10.72)[بله],
  ln((m(7.0), 11.65), (m(7.0), 12.15)),
  lb(m(6.4), 11.9)[خیر],
  // K -> F, F -> L
  ln((m(9.4), 12.55), (m(12.0), 12.55), (m(12.0), 11.6)),
  ln((m(13.3), 11.6), (m(13.3), 13.45)),
)
