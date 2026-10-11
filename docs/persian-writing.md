# Persian writing in Karun reports

The repository includes [ali2000hos/persian-writing](https://github.com/ali2000hos/persian-writing),
version **1.4.0**, pinned to upstream commit
[`75fcdf313fab65d6d205500ca50f9cb52db25783`](https://github.com/ali2000hos/persian-writing/tree/75fcdf313fab65d6d205500ca50f9cb52db25783).
The upstream package is vendored in
`.agents/skills/persian-writing/` and mirrored into `.claude/skills/persian-writing/`.
Its original license, references, scripts, assets, and tests are retained.
The only entrypoint adaptation moves the upstream `compatibility` frontmatter
field under `metadata` for compatibility with the Codex skill validator; the
writing instructions and upstream version are unchanged.

## When to use it

For Persian writing, editing, and translation, load the
[skill](../.agents/skills/persian-writing/SKILL.md), then its
[writing-style](../.agents/skills/persian-writing/references/writing-style.md) and
[orthography](../.agents/skills/persian-writing/references/orthography.md) references.
Read academic or technical-content guidance only when appropriate to the report.
Use a formal, natural register for professional reports; a casual user request
does not make the deliverable colloquial. Preserve facts, qualifications,
citations, and the user's requested degree of editing.

Codex: `$persian-writing`. Claude Code: `/persian-writing`.
The Karun report skill explicitly routes Persian work to this companion.

## Compatibility rules for this template

These are the repository's integration rules for Karun Typst reports; they
take precedence over upstream defaults for other document formats.

- **Rendering:** the Karun template owns RTL, pagination, tables, and fonts.
  Keep Dubai/B Nazanin and the optional house-style helpers. Do not install or
  substitute Vazirmatn/Lalezar for a normal Karun build. Word/PowerPoint/HTML
  recipes and OOXML checks are not Typst instructions.
- **Ezafe:** keep `ه‌ی`, not `هٔ` or `ۀ`. Upstream `--edit` includes `fix_ezafe`,
  which changes this spelling. Do not use that default pipeline for Karun prose.
- **Numbers and tokens:** retain supplied document IDs, standards, quantities,
  units, URLs, code, and version strings. Do not globally convert digits. Use
  Persian digits in ordinary prose where appropriate without changing values;
  preserve intentional quotations and follow the template's `sn`/`lt`/`nb`
  conventions in the optional house style.
- **Source safety:** upstream cleanup protects Markdown constructs, not Typst
  syntax. Never run cleanup or `fa_lint.py --fix` on `.typ` files. If automated
  cleanup helps, work on a separate plain-prose draft, review the differences,
  then transfer only approved prose edits into the report. Do not insert bidi
  control characters into Typst to imitate chat-app layout.
- **Editing scope:** suggestions about register, punctuation, and repetitive
  phrasing are not permission to rewrite supplied quotations or technical claims.
  Do not remove information to satisfy a linter.

## Optional prose checks

From the repository root, on a separate plain-text draft in the ignored build
directory, this limited pipeline fixes Arabic letter variants and common verbal
ZWNJ spacing without applying ezafe or digit conversion:

```sh
python .agents/skills/persian-writing/scripts/persian_cleanup.py --steps fix_arabic_chars,fix_zwnj_verbs --in typst/build/persian-draft.txt --out typst/build/persian-reviewed.txt
python .agents/skills/persian-writing/scripts/fa_lint.py --check typst/build/persian-reviewed.txt
```

Review suggestions contextually. The linter may flag intentional technical tokens
or the template's spelling. It does not validate Typst layout. Finish with the
normal report build and rendered-page inspection described in `AGENTS.md`.

## Updating the vendored package

Review a specific upstream commit before replacing the canonical package.
Preserve upstream content and record the new revision here. Reapply the
frontmatter compatibility adaptation and regenerate the universal edition with
`python -X utf8 -B .agents/skills/persian-writing/scripts/build_universal.py`. Maintain Karun-specific
adaptations in this document and the report skill, not in upstream sources.
Retain upstream and font licenses; see [third-party notices](../THIRD_PARTY_NOTICES.md).
Run the upstream tests and sync both agents:

```sh
python -B -m unittest discover -s .agents/skills/persian-writing/tests
python scripts/sync_skills.py
python scripts/sync_skills.py --check
```

Use `-B` to avoid introducing Python cache files into the vendored skill mirror.
CI runs the upstream tests alongside mirror checks and the template builds.
