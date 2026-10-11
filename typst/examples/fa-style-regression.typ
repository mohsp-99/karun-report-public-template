// =============================================================================
// fa-style-regression.typ — compact visual regression for the hand-numbered
// Persian report style (karun-fa-style.typ + the docs/persian-style.md conventions).
//
// Covers: the Dubai setup block (cover + TOC in Dubai), fa-refine, sn compound
// numbers, ktable/ptable (zebra + repeating header across a page break),
// price-table, note/code/todo/fa-enum, lt/nb bidi tokens, fa-flow (per-row),
// fa-chain and fa-diagram.
//
// Build from inside typst/examples/:
//   typst compile --root .. --font-path ../fonts fa-style-regression.typ \
//     "../build/FA Style Regression.pdf"
// =============================================================================

#import "../template/karun.typ": *

// Self-contained metadata so the example stands alone.
#let meta = (
  title: "آزمون سبک فارسی دستی",
  subtitle: "کتابخانه‌ی همراه karun-fa-style و قراردادهای FA-STYLE",
  summary_title: "آزمون سبک فارسی",
  employer: "قالب گزارش کارون",
  producer: "آزمون رگرسیون",
  access_level: 3,
  confidentiality: 1,
  doc_id: "KARUN-FA-STYLE-REGRESSION",
  date: "۱۴۰۵/۰۶/۱۰",
  year: 2026,
)

#show: karun-report.with(lang: "fa", meta: meta)

// Dubai is the company body font; MUST come before the title and contents
// pages so the cover and the TOC do not stay in B Nazanin.
#set text(font: "Dubai")

#title-page(meta, lang: "fa")

// Open the gap between contents entries — Dubai's line-box is shorter than
// B Nazanin's, for which the engine's leading is tuned.
#show outline.entry: it => block(above: 12pt, below: 0pt, it)
#contents-page(lang: "fa")

#import "../template/karun-fa-style.typ": *
#show: fa-refine

// Land Dubai on the same ~1.5x line spacing the engine gives B Nazanin.
#set text(size: 11.5pt)
#set par(leading: 0.82em, spacing: 1.3em)

// --- Per-report local helpers (docs/persian-style.md §3) ------------------------------

#let newsec() = pagebreak(weak: true)

#let fig-caption(body) = block(above: 7pt, below: 16pt, width: 100%)[
  #set align(center)
  #set par(justify: false)
  #text(size: 9pt, fill: rgb(90, 100, 114), style: "italic")[#body]
]

#let tbl-caption(body) = block(above: 14pt, below: 6pt, width: 100%, sticky: true)[
  #set align(center)
  #set par(justify: false)
  #text(size: 9.5pt, fill: karun-blue, weight: "medium")[#body]
]

#let tnote(body) = block(above: 6pt, below: 16pt, width: 100%)[
  #set par(justify: true, leading: 0.7em)
  #text(size: 9pt, fill: rgb(90, 100, 114))[#body]
]

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

#let nb(body) = box(body)
#let lt(body) = box(text(dir: ltr, body))

// ===========================================================================

= ۱. اعداد مرکب و انضباط دونویسه‌ای

شماره‌ی بخش‌ها در همین متن سرصفحه نوشته می‌شود و شماره‌گذاری خودکار خاموش
است. ارجاع درون‌متنی به بند #sn[۱-۲.] و بند #sn[۱۰-۳.] باید رقم فصل را در
سمت راست نگه دارد و نقطه‌ی پایانی در انتها بماند. نشانه‌های فنی لاتین مانند
#lt[175 mm] و #lt[10 m/s] و #lt[IEC 61587-1] باید یکپارچه و چپ‌به‌راست دیده
شوند، و کد مدل آمیخته مانند #nb[A-۱] باید یک‌تکه بماند. اصطلاح فنی در نخستین
کاربرد با معادل انگلیسی می‌آید — پیچ اسیر پنل (Captive Panel Screw).

== #sn[۱-۱.] فهرست‌ها و یادداشت

#show: fa-enum

+ گزینه‌ی نخست فهرست شماره‌دار با رقم فارسی.
+ گزینه‌ی دوم؛ شناسه‌ی #code[پروفیل-۲۰۲] باید در جعبه‌ی رنگی پیوسته بماند.
+ گزینه‌ی سوم با نشانه‌ی #lt[ISO 2768] در میانه‌ی جمله.

#note[
  این بند نقل‌قول است و باید در قاب کم‌رنگ با خط آبی در لبه‌ی راست دیده شود؛
  قاب هرگز میان دو صفحه نمی‌شکند.
]

کارهای باز این بخش: #todo تکمیل نقشه‌ها، #todo بازبینی متن فنی.

#newsec()
= ۲. جدول‌ها

#lead[
  این مقدمه‌ی کوتاه با «جدول ۱» هم‌صفحه می‌ماند؛ عنوان جدول بالای آن است.
]

#tbl-caption[جدول ۱ — مشخصات کلیدی نمونه.]
#ptable(
  columns: (1fr, 1.6fr),
  [جنس پروفیل], [آلومینیوم 6063-T6],
  [پهنای مفید], lt[84 HP],
  [استاندارد مرجع], lt[IEC 60297-3-100],
)
#tnote[
  یادداشت جدول: مقدارها نمونه‌ی آزمون‌اند و تنها برای بررسی چیدمان به کار
  می‌روند.
]

#tbl-caption[جدول ۲ — ستون نخست وسط‌چین با «centred-first».]
#ktable(
  columns: (auto, 1fr, auto),
  align: centred-first,
  [ردیف], [شرح], [وضعیت],
  [۱], [قاب اصلی ساب‌رک], [تأیید],
  [۲], [ریل راهنمای کارت], [تأیید],
)

#tbl-caption[جدول ۳ — جدول بلند راه‌راه؛ سربرگ باید در صفحه‌ی بعد تکرار شود.]
#ktable(
  breakable: true, zebra: true,
  columns: (auto, 1fr, auto),
  [ردیف], [شرح آزمون], [نتیجه],
  ..range(26).map(i => (
    [#to-fa-digits(i + 1)],
    [سطر آزمایشی برای بررسی تکرار سربرگ و راه‌راه شدن ردیف‌های زوج],
    [تأیید],
  )).flatten(),
)

#tbl-caption[جدول ۴ — جدول قیمت با کادر پررنگ‌تر و سلول‌های وسط‌چین.]
#price-table(
  columns: (1.4fr, 1fr, 1fr),
  [شرح], [تعداد], [بهای واحد (ریال)],
  [ساب‌رک #nb[A-۱]], [۱۰], [۸۵۰٬۰۰۰],
  [ریل راهنما], [۲۰], [۱۲۰٬۰۰۰],
)

= ۳. بخش کوتاه بدون صفحه‌ی نو

این بخش عمداً کوتاه است و بدون «newsec» در ادامه‌ی بخش پیش می‌آید تا صفحه‌ی
دوسوم‌خالی پدید نیاید.

#newsec()
= ۴. نمودارها

#fa-diagram(
  fa-flow(
    [دریافت نیازمندی], [طراحی اولیه], [نمونه‌سازی],
    [آزمون], [اصلاح], [تحویل],
    per-row: 3,
  ),
  caption: [روند شش‌گامه در دو ردیف؛ شمارنده و رنگ پیوسته ادامه می‌یابد.],
)

#fa-diagram(
  fa-chain(
    (title: [برش پروفیل], body: [برش به طول سفارش با رواداری #lt[ISO 2768]]),
    (title: [ماشین‌کاری], body: [سوراخ‌کاری قاب مطابق نقشه‌ی مشتری]),
    (title: [مونتاژ نهایی], body: [کنترل ابعادی و بسته‌بندی]),
  ),
  caption: [زنجیره‌ی سه‌گامه‌ی تولید با شمارنده‌ی «گام».],
)
