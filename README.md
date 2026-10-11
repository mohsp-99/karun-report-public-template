# Karun Report Public Template

A Typst template for branded Karun PDFs in **English (LTR)** and
**Persian (RTL)**, with a cover, metadata, table of contents, branded tables,
pagination helpers, and diagrams. Ready for Codex and Claude Code, or manual use.

## Quick start

Use GitHub's **Use this template** button to create your own repository, or clone:

```sh
git clone https://github.com/mohsp-99/karun-report-public-template.git
cd karun-report-public-template
```

Install [Typst](https://github.com/typst/typst/releases/tag/v0.15.1) (tested with
0.15.1). Python 3.10+ is optional for the convenience scripts; they use only the
standard library. The included Dubai and B Nazanin fonts are used automatically
by the build command; see [font notes](typst/fonts/README.md).

1. Fill `typst/report/metadata.typ` with your metadata.
2. Replace the sample body in `typst/report/report.typ` and set all three
   language arguments to `"en"` or `"fa"`.
3. Put supplied figures in `typst/report/figures/`.
4. Build from the repository root:

```sh
python scripts/build.py
```

Output: `typst/build/report.pdf`. To build without Python:

```sh
typst compile --root typst --font-path typst/fonts typst/report/report.typ typst/build/report.pdf
```

## Work with an agent

Open **this repository root** in Codex or Claude Code. Project instructions and
the report skill are checked in; no global skill installation is needed.

| Agent | Repository guide | Discoverable report skill |
| --- | --- | --- |
| Codex | `AGENTS.md` | `.agents/skills/karun-report-typst/SKILL.md` |
| Claude Code | `CLAUDE.md` imports `AGENTS.md` | `.claude/skills/karun-report-typst/SKILL.md` |

Example request (attach your content and metadata):

> Use the karun-report-typst skill to turn the supplied content into a Persian
> Karun report. Preserve the facts, build the PDF, and inspect the rendered pages.

Codex can explicitly invoke `$karun-report-typst`; Claude Code can invoke
`/karun-report-typst`. Reopen the project/session after adding or updating skills
if the client has cached discovery. The skill is repository-local and depends
on the checked-out template; copying only its folder into a global skills
folder is not a standalone installation.

## Organization

```text
AGENTS.md                         Shared repository guidance
CLAUDE.md                         Claude entrypoint importing AGENTS.md
.agents/skills/karun-report-typst/ Canonical report skill for Codex
.claude/skills/karun-report-typst/ Generated Claude Code mirror
.github/workflows/validate.yml    Build and skill consistency checks
scripts/                         Cross-platform build and skill sync; Linux setup
docs/                            Authoring and specialized style references
typst/
  report/                        Editable report.typ, metadata.typ, figures/
  template/                      Shared engines and brand/ artwork
  fonts/                         Dubai and B Nazanin
  examples/                      Regression documents
  build/                         Generated PDFs/PNGs (gitignored)
```

## Validation and maintenance

```sh
python scripts/build.py --examples --render
python scripts/sync_skills.py --check
```

The render command prints separate page directories for visual inspection.
Compilation alone cannot verify layout or RTL order. Maintain the skill under
`.agents/skills/`, then run `python scripts/sync_skills.py` and commit both copies.
CI checks skill parity and compiles the starter plus every regression example.

### Persian writing companion

The bundled [persian-writing skill](https://github.com/ali2000hos/persian-writing)
helps both agents with Persian register, wording, orthography, and prose checks.
It is available as `$persian-writing` in Codex or `/persian-writing` in Claude
Code and is linked from the report workflow. See
[integration rules and pinned version](docs/persian-writing.md), including how
to preserve Karun's ezafe spelling, fonts, and Typst syntax.

- [Authoring and tables](docs/authoring.md)
- [Diagram toolkit](docs/diagrams.md)
- [Optional Persian house style](docs/persian-style.md)
- [Maintenance, discovery, and migration](docs/maintenance.md)
- [Third-party assets](THIRD_PARTY_NOTICES.md)

## Cloud setup

In a Linux environment with this repository already checked out, run:

```sh
bash scripts/cloud-setup.sh
export PATH="$HOME/.local/bin:$PATH"
python3 scripts/build.py --examples
```

The setup script installs a pinned Typst version when Typst is absent. It leaves
Git history, report content, and remotes intact. Use it in the environment setup
step for either agent. It needs access to GitHub release downloads and requires
`curl` and `tar`; it does not require root privileges.

## Troubleshooting

If Typst is missing, install it and restart the terminal/agent so PATH refreshes.
If imports are outside the root, use the commands above with `--root typst`.
If fonts are missing, include `--font-path typst/fonts`. Keep real reports and
confidential assets in your own workspace; review source changes before pushing
to a public repository. Generated PDFs and pages are ignored by Git.
