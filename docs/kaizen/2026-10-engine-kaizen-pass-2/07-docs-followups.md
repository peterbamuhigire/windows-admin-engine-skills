# Documentation pass: follow-ups (31 October 2026)

The documentation pass (branch `kaizen/2026-10-docs`) rewrote `README.md` ("Quality and improvement", "Validation", installation notes), the quality-gate and kaizen paragraphs of `AGENTS.md`, two rows of the operator manual and one pointer in the test plan, and added `docs/README.md`. It did not edit any skill, validator, manifest or evidence record. The items below are things it found and left alone.

## Corrections to earlier records (not edited)

| Record | Statement | Measured on 2026-10-31 |
|---|---|---|
| `05-final-report.md` (residual risk) and `06-next-cycle.md` (decision 3) | The source-register gate turns red on 2026-11-11 | `python3 -X utf8 scripts/check_source_register.py --as-of 2026-11-06` exits 1 with one finding: `policy.scoped_october_review_date` is 2026-11-05. The 39-finding failure is on 2026-11-11, as recorded. `04-validation-record.md` line 93 already names the policy date. |
| `06-next-cycle.md` (re-audit date) | Re-audit on 5 November, before 2026-11-10 | Consistent: 2026-11-05 is the last green day |

## Registered validators and manifest (decision for Peter)

- `.skills-engine/engine-manifest.yaml` registers `python -X utf8 -m unittest discover -s tests/python -v`, which runs 72 tests. `tests/test_approval_adapter.py` (1 test) is outside that root, so the registered command skips it; `pytest` from the repository root collects 73. Either move the file under `tests/python/` or register a second command. A documentation edit cannot fix this.
- The same manifest and `.github/workflows/ci.yml` do not run the two hook tests (`hooks/test-destructive-bash-gate.js`, 61 of 61; `hooks/test-plugin-hook-config.js`, 7 of 7). Both run on Linux with Node.js. Register them if the hooks are meant to be gated.
- `python` is used in the manifest commands and `python3` in the documentation. `python` resolves on the Linux workstation today, so nothing fails; the difference is only a portability note.

## Not run in this pass

- `pip install .` (README "Catalogue CLI"): packages may not be installed on the workstation. The module entry point `PYTHONPATH=python python3 -X utf8 -m windows_admin.cli` was run and works.
- Every PowerShell command and gate: `pwsh: command not found`, exit 127.
- `scripts/verify_source_urls.py`: network liveness was not re-run; the 31 October record holds 46 of 46 reachable.

## Cross-engine findings (no other repository edited)

- The coordination package's `render_host_files.py --check` reports `[shared-asset-unregistered-variant]` for `scripts/routing_smoke_test.py` in this repository: K6c changed the file, and its hash is not a registered variant in the coordination package's `catalog/shared-assets.yaml`. The registration belongs to that package.
- Research engine naming: `gh api repos/peterbamuhigire/digital-research-skills` resolves to the repository `peterbamuhigire/chwezi-research-engine`, so `digital-research-skills` behaves as a redirect and `chwezi-research-engine` is the canonical GitHub name today. `engine/source-register.yaml` (line 8) says `digital-research-skills`, `AGENTS.md` says `digital-research-engine` in portfolio-managed sentences, and the documentation avoids naming the repository. The portfolio owner should settle one name.
- The coordination package's `catalog/engines.yaml` still lists three validators for this engine (see `06-next-cycle.md`).

## Decisions left open

- `CHANGELOG.md`: this engine has never kept one, and none was created. Five sibling engines do. The pass-2 changes and their commit hashes are in `05-final-report.md` ("Kept changes"). Create one only if Peter wants the engine to follow the sibling convention.
- `docs/kaizen/tool-controller-contract.md` and `docs/kaizen/pipeline-binding-review.md` carry an author line that includes a personal telephone number. It is published as a business byline, but it is personal data in tracked text; Peter should confirm it stays.
- `docs/release/delivery-evidence-pack.md` and `docs/release/community-structure-cleanup-2026-08-12.md` still name `skills-web-dev` (the former local directory of `chwezi-dev-engine`). They are dated records and were left as written; `docs/README.md` states that dated records are not refreshed.
- The operator manual header still reads "Last reviewed: 2026-08-12", and its engine release `0.1.0` against plugin version `1.1.0` is the version question already open in `06-next-cycle.md`. Only two rows were corrected; the manual was not re-reviewed in full.

## Skills

No `SKILL.md` was changed or found to contradict the new documentation. The skills were not re-read in full in this pass.
