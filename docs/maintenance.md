# Maintenance

## Agent discovery and a single source of truth

`AGENTS.md` is the shared repository policy. `CLAUDE.md` imports it using Claude
Code's `@AGENTS.md` syntax, so improvements apply to both agents.

Codex discovers the canonical skill in `.agents/skills/karun-report-typst/`.
Claude Code discovers its checked-in mirror in `.claude/skills/karun-report-typst/`.
Both skill files link to the same detailed references in `docs/`. They require
the complete repository and are not independently installable skill bundles.

After editing canonical skill files:

```sh
python scripts/sync_skills.py
python scripts/sync_skills.py --check
```

Mirrors are ordinary files so Windows clones do not require symlink privileges.
The sync script fails on unexpected mirror files instead of deleting them.
Remove intentionally retired files explicitly, then synchronize. CI fails on
missing or changed mirrors. No model, account, hooks, or tool permissions are
forced by this repository.

Official references:

- [OpenAI: repository policy and .agents/skills](https://developers.openai.com/blog/skills-agents-sdk)
- [Claude Code: project skills](https://code.claude.com/docs/en/skills)
- [Claude Code: instruction imports](https://code.claude.com/docs/en/memory)

## Migrating older reports

| Previous path | Current path |
| --- | --- |
| `typst/report.typ` | `typst/report/report.typ` |
| `typst/metadata.typ` | `typst/report/metadata.typ` |
| `typst/karun*.typ` | `typst/template/karun*.typ` |
| `typst/images/` brand artwork | `typst/template/brand/` |
| `typst/images/` report figures | `typst/report/figures/` |
| `typst/SKILL.md` | `.agents/skills/karun-report-typst/SKILL.md` |
| `typst/README.md` | `docs/authoring.md` |
| `typst/DIAGRAMS.md` | `docs/diagrams.md` |
| `typst/FA-STYLE.md` | `docs/persian-style.md` |

From `typst/report/report.typ`, import `../template/karun.typ` and the sibling
`metadata.typ`. Companion imports use `../template/karun-diagrams.typ` or
`../template/karun-fa-style.typ`. Figure paths use `figures/your-figure.png`.
Use the root-level build commands in `AGENTS.md`; the explicit Typst root allows
imports and shared assets across these directories.

## Verification

For shared behavior or asset changes, compile the report and all examples with
`python scripts/build.py --examples --render`. Inspect relevant pages for layout,
font fallback, RTL order, and pagination. A path-only migration should produce
the same rendered pages as before. Add regression content when behavior changes,
not merely to restate an implementation.

CI uses the pinned Typst installer, checks skill parity, and compiles all examples.
It does not certify visual correctness. To update the tested Typst version,
update `scripts/cloud-setup.sh`, the documented baseline, and verify the examples.
The installer never clones over existing files or deletes `.git`.

The public template starts with an independent history. Its remote is separate
from the original private repository; do not push private history into it.
