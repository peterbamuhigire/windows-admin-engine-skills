# README kaizen record, 31 October 2026

Peter Bamuhigire asked for the READMEs of the Chwezi engines to be "smarter and better reading overall". This record covers one scoped cycle on `README.md` of the Windows Administration Skills Engine, run with the portfolio steps (Observe, Baseline, Select, Experiment, Check, Standardise, Teach, Re-measure). It is a scoped cycle: **no score is published**, and the engine's published score (59.5) is unchanged.

Branch `kaizen/2026-10-readme-kaizen`, created from `main` at `2ef8121` with a clean tree (`git status --porcelain`: 0 lines). This engine keeps no `CHANGELOG.md`, and none was created. Toolchain: Python 3.14.8 and Node.js 22.23.1 on Linux. There is no `pwsh` on the host. No skill body, script, test or manifest was edited.

## Observe

Measured with a read-only readability script (`readme-metrics.py`) on `README.md` at `2ef8121`:

| Measure | Baseline |
|---|---|
| `words` | 5,500 |
| `h2` | 5 |
| `toc` (contents list before the third H2) | 0 |
| `first_cmd` (line of the first fenced block) | 88 |
| `longest_sec` (words in the longest H2) | 2,832 |
| `long_lines` (lines over 300 characters) | 33 |
| `max_line` (characters) | 1,386 |
| `sent_len` (mean words per prose sentence) | 14.1 |
| `fre` (Flesch reading ease) | 46 |

What this meant for a reader:

- The first runnable command sat 88 lines down, behind a 309-word opening and a 2,832-word section that mixed status, open findings, a calendar and a 2,025-word itemised list.
- The References section held 912 words of citations after the install and validation material.
- The opening was two paragraphs of 309 words, with no list of facts and no contents.

Interfaces found before editing:

- Other files link three README anchors: `#validation` (`docs/README.md`, `docs/testing/test-plan.md`), `#quality-and-improvement` (`docs/README.md`) and `#what-the-october-2026-kaizen-improved` (`docs/README.md`).
- `AGENTS.md` names README sections in prose, "Quality and improvement" (score, open findings, calendar) and "Validation" (commands and results). Both headings are kept, and the calendar stays inside "Quality and improvement".
- `scripts/check_marketplace.py` scans `README.md` for machine-bound paths, and `scripts/check_content_hygiene.py` resolves its local links and `windows-*` identifiers. No script reads README headings or section text.
- A read-only search of the sibling checkouts found no link to a README anchor of this engine. One sibling file, the engine tour in `chwezi-engine-agents`, names the README path only.

Validators before any edit (all on Linux, 2026-10-31):

| Command | Exit |
|---|---|
| `validate_engine.py`, `routing_smoke_test.py`, `source_ingestion_guardrail.py`, `check_source_register.py` | 0, 0, 0, 0 |
| `validate_command_tree.py`, `validate_operator_manual.py`, `validate_fleet_manifest.py` (valid fixture) | 0, 0, 0 |
| `python3 -X utf8 -m unittest discover -s tests/python` (72 tests), `unittest tests/test_approval_adapter.py` | 0, 0 |
| `node hooks/test-destructive-bash-gate.js` (61 of 61), `node hooks/test-plugin-hook-config.js` (7 of 7) | 0, 0 |
| `check_marketplace.py`, `check_content_hygiene.py` | 0, 0 |
| `pwsh -NoProfile -File scripts/test-powershell-syntax.ps1` | 127, `pwsh: command not found`: `NOT_ASSESSED` |

## Select

| Item | Decision | Reason |
|---|---|---|
| R1 Front door | Applied | The opening is three plain sentences, a who-and-when line, six measured facts and three numbered steps (clone, check, route). The first fenced command is on line 24. |
| R2 Contents | Applied | A ten-entry contents list follows "Start here". All 13 in-page links resolve (preservation check). |
| R3 Structure | Applied | 5 H2 sections became 11, with H3 children. The 2,832-word section was split into Validation, Quality and improvement (four H3 parts, including the calendar) and a separate October kaizen section. |
| R4 Find the right skill | Applied | A 12-row task table uses routing-fixture tasks. Each of the 12 skills exists under `skills/`, and the catalogue CLI ranked it first for the fixture wording (run for all 12). The risk column comes from `windows-admin list`. |
| R5 No walls of text | Applied | Lines over 300 characters fell from 33 to 1. The remaining one is a bullet of four evidence links. |
| R6 Plain English | Applied | Sentences, bullets and table cells were shortened; the Codex, Catalogue CLI and Validation paragraphs became bullets. |
| R7 Say it once | Applied | The fleet-manifest refusal list is stated once (Quality and improvement) and cross-referenced from the K1 item. The "Manual use" paragraph no longer repeats the gate list. |
| R8 Relocate bulk | Applied twice | (1) The 912-word References section moved to `docs/references.md`. (2) The 2,025-word itemised kaizen list moved to `docs/kaizen/october-2026-improvements.md`. Each leaves a short summary and a link. No script, test or router reads either block. |
| R8 for the 20-row skill table | Skipped | It has 20 rows, under the threshold of about 50, and it is the place the skill count is stated. |
| R8 for the date-gate calendar | Skipped | `AGENTS.md` sends readers to the README for the calendar, and the calendar is short (8 rows). |
| R8 for the Validation tables | Skipped | `AGENTS.md` names README "Validation" as the home of each command's measured result. |

## Experiment

| Commit | What it changed |
|---|---|
| `79248c7` | Relocation. Added `docs/references.md` and `docs/kaizen/october-2026-improvements.md`, with the original wording. Link paths and two cross-references were re-based, and the stale "744 checkout files" figure was dated as measured at the time. `docs/README.md` indexes both pages. |
| `3f61721` | Structure, front door and plain English. Rewrote `README.md` (see Select) and updated the `docs/README.md` lines that describe the README and the calendar. These two themes were done in one pass because each section was restructured and shortened together, so they share a commit. |
| `3e5acd7` | Fix after the first preservation run. The README links the kaizen backlog, experiment logs, validation records and `docs/safety-model.md` directly. |
| `eb922d2` | Added H2 headings to the relocated itemised page, which had none. |
| the commit that adds this file | The record, and the `docs/README.md` index row for it. |

Deliberate corrections and changes of fact, all checked before they were written:

- The README no longer states "325 package and 744 checkout files". The checkout count includes `.git`, so it changes on every commit (753 before this cycle, 783 at the final run). The relocated page keeps the figure, dated as measured at the time, with the command that gives the current value. The package count is 328 after the three new files (325 before).
- "Run today" and "Exit 0 today" became "Run on 2026-10-31" and "Exit 0 on 2026-10-31", so the text does not go stale.
- The calendar gained a 2026-11-10 row and a bold first-red-day line (2026-11-06). The row was measured: `--as-of 2026-11-10` exits 1 with one finding.
- The "Installation" heading became "Install and update", and "Capabilities" became "What is inside". The "Install and update" section now says how to update the direct command tree (run the installer again after `git pull`; a repeat run with nothing to change reports `Mode=NoChange`), sourced to `docs/release/idempotent-installer-2026-08-12.md`. No update command was invented for the plugin or the clone installer.
- A short "Contributing, author and licence" section was added. The licence (GPL-3.0-only) and author come from `pyproject.toml`, `.claude-plugin/marketplace.json` and `LICENSE`; the contribution rules come from `AGENTS.md`, "Change discipline".
- The 12 tasks in the new table use the wording of routing fixtures, shortened in two cases ("Assess Defender, BitLocker and baseline drift"). The README says the CLI ranks each skill first for the fixture wording, which was checked.

## Check

Validators after the last edit, same commands and exit codes as before:

| Command | Exit before | Exit after |
|---|---|---|
| `validate_engine.py` | 0 | 0 (19 skills, 0 findings; package 325 to 328 files, checkout 753 to 783 at the final run) |
| `routing_smoke_test.py`, `source_ingestion_guardrail.py`, `validate_command_tree.py`, `validate_operator_manual.py`, `validate_fleet_manifest.py` | 0 | 0, output byte-identical |
| `check_source_register.py` | 0 | 0 |
| `unittest discover -s tests/python`, `unittest tests/test_approval_adapter.py` | 0 | 0 (72 tests; 1 test) |
| the two `node hooks/` tests | 0 | 0 |
| `check_marketplace.py`, `check_content_hygiene.py` | 0 | 0 |
| `pwsh -NoProfile -File scripts/test-powershell-syntax.ps1` | 127 | 127: `NOT_ASSESSED` |

Other checks:

- **Calendar.** `check_source_register.py --as-of` was run for the nine dates in the README (2026-10-31, 11-05, 11-06, 11-10, 11-11, 12-01, 12-24, 2027-01-30 and 2027-02-01) before and after the edits. Exit codes were 0, 0, 1, 1, 1, 1, 1, 1, 1 and the finding counts 0, 0, 1, 1, 39, 43, 45, 54, 56, matching the table. Each output file was byte-identical before and after. The first red day is 2026-11-06.
- **Independent counts.** 20 `SKILL.md` files and 12 folders under `skills/` (`find` and `ls`); 56 register rows, 46 URL rows and 9 `verified` rows (a separate Python parse of `engine/source-register.yaml`); 73 routing fixtures (`tests/fixtures/routing.json`); all 23 commit hashes named in the original README section are ancestors of `main` (`git merge-base --is-ancestor`).
- **pytest.** `python3 -m pytest` fails on the host (module not installed), so the README's "pytest collects 73 tests, and all pass" was re-measured with a pytest already present in a scratch virtual environment outside the repository: `73 passed, 170 subtests passed`. Nothing was installed.
- **Not assessed.** Every PowerShell gate (exit 127), and the `NOT_ASSESSED` statements in the README, are unchanged. No Windows host was touched.

Preservation check (`readme-preserve-check.py <repo> main kaizen/2026-10-readme-kaizen`, run after the fix commit):

```text
links: old README 67 targets; new README 22; moved to docs 50; LOST 0
commands: old README 32; kept in README 32; moved to docs 0; LOST 0
anchors: 5 README.md#<anchor> links in tracked files; BROKEN 0
in-page links: 13 anchors used; BROKEN 0
RESULT: OK
```

In the output above the literal `anchor` after the hash is written as `<anchor>`, because the checker reads the text it prints as a link to a heading called "anchor" and reports it BROKEN. The first run reported six LOST links (the kaizen backlog, two experiment logs, two validation records and `docs/safety-model.md`). They had moved into the relocated page, where the check does not recognise a re-based relative path as the same target. The fix commit restored direct links in the README. No command was replaced or removed.

Metrics after (`README.md`):

| Measure | Baseline | After | Target | Result |
|---|---|---|---|---|
| `words` | 5,500 | 4,394 | at most 5,775; aim 4,950 | met (-20.1%) |
| `h2` | 5 | 11 | none | |
| `toc` | 0 | 1 | 1 | met |
| `first_cmd` | 88 | 24 | 40 or less | met |
| `longest_sec` | 2,832 | 1,010 | 1,500 or less; 1,200 preferred | met |
| `long_lines` | 33 | 1 | 16 or less | met |
| `max_line` | 1,386 | 357 | 700 or less | met |
| `sent_len` | 14.1 | 12.1 | 16.5 or less | met |
| `fre` | 46 | 54 | no lower than 46; aim 51 | met (+8) |

Caveats on those numbers:

- `sent_len` and `fre` are measured over prose paragraphs only, outside bullets, tables and headings. Moving text into bullets and tables lowers `sent_len` without the sentences themselves getting easier, so the 12.1 overstates the gain. The prose that remains is shorter, and the sentence-level edits were real, but the figure is a proxy.
- The README is 1,106 words shorter, but the three files together hold more. `docs/references.md` has 939 words and the relocated page 2,077, so the total is 7,410 against 5,500. The README keeps a summary of each relocated block, and the front door, contents and skill table are new. The relocated page keeps its original long lines (17 over 300 characters, longest 1,302). It was moved, not rewritten.
- No miss against the targets. The metrics script is a proxy for readability, not a test of it. No reader test was run.

## Standardise

Conventions for the next editor of `README.md`:

1. **Order.** Title and purpose, "At a glance" (five or six measured facts), "Start here" (three numbered steps with exact commands), contents, when to use it with a task-to-skill table, how it works, what is inside, install and update, validation, quality and improvement, the October kaizen summary, references, contributing and licence.
2. **Limits.** The first fenced command by line 40. Every H2 at most 1,200 words. Paragraphs at most 90 words. Table cells at most 35 words. Lines at most 300 characters, except a row of links. Mean sentence 16 words or fewer.
3. **Linux and PowerShell split.** Keep "Runs on Linux, macOS and Windows" and "Needs PowerShell: `NOT_ASSESSED` on the Linux host" as separate tables. A command moves between them only after it has run on a host of the stated kind.
4. **Dated figures.** Write "on 2026-10-31", never "today". Do not state a checkout file count: it includes `.git`.
5. **Linked headings.** Keep `## Validation`, `## Quality and improvement` (with the score, the open findings and the calendar inside it) and the heading "What the October 2026 kaizen improved". Other files and `AGENTS.md` depend on them. After any heading change, run the preservation check and search tracked files for `README.md#`.
6. **Relocation.** Move bulk to `docs/` only with a summary and link left behind, and index the new page in `docs/README.md`.

Figures in "At a glance" and the Validation tables, and the command that re-measures each:

| Figure | Command |
|---|---|
| 20 skills, 12 folders | `find skills -name SKILL.md`, `ls skills` |
| 48 `wsa-` commands | `python3 -X utf8 scripts/validate_command_tree.py` |
| 73 fixtures, 11 of 19 coverage | `python3 -X utf8 scripts/routing_smoke_test.py` |
| 72 tests | `python3 -X utf8 -m unittest discover -s tests/python` |
| 56 rows, 46 URL rows, 35 warnings, the calendar | `python3 -X utf8 scripts/check_source_register.py` and `--as-of <date>` |
| 19 specialist skills, file counts | `python3 -X utf8 scripts/validate_engine.py` |

## Teach

- Put the thing a reader came to run within the first 40 lines, and move citations and itemised history into `docs/` with a summary left behind.
- Before renaming or moving a README heading, search tracked files for `README.md#` and read what `AGENTS.md` says about README sections.
- Re-run the `--as-of` rows of the calendar whenever the source register changes, and update the README on the same day.

## Re-measure and next cycle

- **Re-measure on 2026-11-06**, the first red day of the date gate, and again when the register is re-verified. Update the calendar, the "At a glance" gate line and `AGENTS.md` together.
- **Finding for the validators, not fixed here (scripts are out of scope):** `scripts/check_content_hygiene.py` strips the `#fragment` of a link (lines 93 and 94), so a broken heading anchor passes. Anchors were checked in this cycle by the preservation script only. A next cycle could add an anchor check to the hygiene scan and a test for it.
- Run a plain-English pass on `docs/kaizen/october-2026-improvements.md`, which was moved verbatim.
- The pass-2 evidence bullet in the README is the only line over 300 characters (four links). Shorten it only if the link text can shrink without hiding what each link is.
- No score is published for this cycle. The next scored cycle should measure the README again with the same script and report it next to the baseline above.
