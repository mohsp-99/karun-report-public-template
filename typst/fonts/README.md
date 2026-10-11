# Bundled fonts

Fonts are bundled so the report builds with the exact look without a system-wide
install. The template picks the font by report language:

- **English** → **Dubai** (`font: "Dubai"`).
- **Persian** → **B Nazanin** (`font: "B Nazanin"`), the traditional Persian
  book face, with Dubai kept as a glyph fallback. Latin runs inside Persian text
  (technical codes, standards, units) are routed back to Dubai so codes like
  `ANT02-A0000` stay in clean Latin digits.

## Dubai (English)

Files (`DubaiW23-*.ttf`): Light (300), Regular (400), Medium (500), Bold (700).
All four share the family name **`Dubai`** and are selected by weight, so
`font: "Dubai"` picks Regular for body text and Bold for headings.

## B Nazanin (Persian)

Files: `BNazanin.ttf` (Regular) and `BNazaninBold.ttf` (Bold), both family
name **`B Nazanin`**. Used at 12pt for Persian body text (the Nazanin family
sits small on the em; 12–13pt is the Persian book standard). Attributed to Borna
Rayaneh in the inherited template. No upstream license file was included.
If you have a licensed copy, it will match. To swap it for another Persian face
(e.g. Vazirmatn), drop the `.ttf`s here and change `font` in `karun.typ`.

## Build using these fonts

Point Typst at this folder with `--font-path` (no system install needed):

```sh
python scripts/build.py  # from the repository root
```

## Rights

The original template attributes Dubai to the Government of Dubai
(<https://dubaifont.com>) and B Nazanin to Borna Rayaneh. No upstream font license
files were included. Free availability is not treated here as proof of permission
to redistribute. See [third-party notices](../../THIRD_PARTY_NOTICES.md).
