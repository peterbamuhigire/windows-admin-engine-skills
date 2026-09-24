# CLAUDE.md — windows-admin-engine-skills (router for Claude Code)

@AGENTS.md

`AGENTS.md` is the runner-neutral router and doctrine for this engine; Claude Code follows it in
full. Skip only its "Codex-only model setup" section.

How to use this engine under Claude Code:

1. Read `AGENTS.md`, then `rules/common/core.md` for any non-trivial task.
2. Glob `skills/**/SKILL.md` and route by frontmatter `description`. Read the `SKILL.md` files
   directly; they are not registered with the native `Skill` tool.
3. Treat every host, domain, or fleet change as preview-first and approval-gated as the routed
   skill specifies. Missing host, lab, source, live, or recovery evidence is `NOT ASSESSED`.
4. Validate changes with the commands declared in `.skills-engine/engine-manifest.yaml`.

## Never store book extractions

Book extractions, book summaries and chapter-by-chapter notes must never be stored in this
repository (no `book-extractions/`, `extracted-books/` or `book-study/` folder, no
`*-extraction.md` book digests). Knowledge from books enters only as paraphrased, task-oriented
skill content and `references/` files (procedures, checklists, decision rules) with a short
citation (Author (Year) *Title*, Publisher). Verbatim quotations stay rare and under 25 words.
Staging notes live outside the repository and are never linked from skills. The portfolio check
`chwezi-engine-agents/scripts/validate-no-book-extractions.py` fails if an extraction folder
appears.
