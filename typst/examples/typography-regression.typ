// =============================================================================
// typography-regression.typ — compact visual regression for Persian typography,
// report-table branding, and page cohesion.
//
// Build from inside typst/examples/:
//   typst compile --root .. --font-path ../fonts typography-regression.typ \
//     "../build/Typography Regression.pdf"
// =============================================================================

#import "../template/karun.typ": *

#let meta = (
  title: "آزمون تایپوگرافی گزارش",
  subtitle: "نمونه‌ی فشرده‌ی فارسی و لاتین",
  summary_title: "آزمون تایپوگرافی",
  employer: "قالب گزارش کارون",
  producer: "آزمون رگرسیون",
  access_level: 3,
  confidentiality: 1,
  doc_id: "KARUN-TYPE-REGRESSION",
  date: "۱۴۰۵/۰۵/۱۷",
  year: 2026,
)

#show: karun-report.with(lang: "fa", meta: meta)
#title-page(meta, lang: "fa")
#contents-page(lang: "fa")

= بررسی تایپوگرافی

این پاراگراف عبارت‌های «بررسی فنی»، «نمونه‌ی خام» و «اندازه‌ی قطعه» را با
املای درست ی‌دار دارد؛ حروف هر واژه باید کاملاً پیوسته دیده شوند و هیچ همزه،
مربع توخالی یا شکستگی میان حروف پدید نیاید. عبارت‌های لاتین ISO 2768،
ANT02-A0000 و 215 MPa نیز باید با قلم Dubai و کمی کوچک‌تر از واژه‌های فارسی
دیده شوند.

#keep-with-next[
  این مقدمه‌ی کوتاه باید همراه با جدول زیر در یک صفحه بماند و به‌تنهایی در انتهای
  صفحه جا نماند.
]

#figure(
  table(
    columns: (1fr, 1.7fr, 1fr),
    table.header([ردیف], [شرح], [نتیجه]),
    [۱], [کنترل نویسه‌ی فارسی], [تأیید],
    [۲], [اندازه‌ی ISO 2768], [تأیید],
    [۳], [رنگ‌بندی جدول], [تأیید],
  ),
  caption: [کنترل‌های دیداری قالب گزارش.],
)

== گروه فشرده

#keep-together[
  این متن کوتاه و جدول جمع‌بندی باید همیشه به‌صورت یک گروه فشرده باقی بمانند.

  #figure(
    table(
      columns: (1fr, 1fr),
      table.header([ویژگی], [انتظار]),
      [قلم جدول], [کوچک‌تر از متن اصلی],
      [سرستون], [آبی کارون با نوشته‌ی سفید],
    ),
    caption: [کنترل پیوستگی گروه کوتاه.],
  )
]
