# Third-party assets

The template includes Karun brand artwork under `typst/template/brand/` and
third-party font binaries under `typst/fonts/`. These assets retain their
respective owners' rights. Public repository availability does not itself grant
a trademark or font redistribution license.

The inherited font set is Dubai (four weights) and B Nazanin (regular/bold).
See [font provenance notes](typst/fonts/README.md). No upstream font license files
were present in the source snapshot; this repository does not assert an open
source license for those binaries. Obtain applicable terms from the respective
rights holders before redistributing or relicensing them.

No blanket open-source license has been added to this template.

## Persian-writing skill

The vendored `ali2000hos/persian-writing` v1.4.0 package is copyright 2026
persian-writing contributors, licensed under the
[MIT license](.agents/skills/persian-writing/LICENSE), with exceptions described
there for fonts and attribution for the bundled dictionary. Its Claude mirror
retains the same notices. See [the pinned source](docs/persian-writing.md).

The package's Vazirmatn and Lalezar fonts retain their upstream SIL Open Font
License 1.1 terms. Copies are included in
[Vazirmatn-OFL.txt](docs/licenses/Vazirmatn-OFL.txt) and
[Lalezar-OFL.txt](docs/licenses/Lalezar-OFL.txt). These fonts belong to the
companion skill; Karun report builds continue to use `typst/fonts/`.
