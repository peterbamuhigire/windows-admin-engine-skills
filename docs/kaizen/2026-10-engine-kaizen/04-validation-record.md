# Validation record — 29 October 2026

Run from the catalogue-resolved Windows engine checkout. No absolute device
binding is required. Python commands use Python 3.14.8. PowerShell commands run
in the disposable `mcr.microsoft.com/powershell:latest` Linux image observed as
PowerShell 7.4.2, with checkout read-only and networking disabled. This is a
fixture runtime, not a current Windows support claim.

| Exact command | Result |
|---|---|
| `python -X utf8 scripts/validate_engine.py` | Exit 0; 19 specialists, zero findings; hard checkout/package file gate included |
| `python -X utf8 scripts/routing_smoke_test.py` | Exit 0; 34/34 first-rank and top-three; seven/seven owned-negative primary checks |
| `python -X utf8 scripts/source_ingestion_guardrail.py` | Exit 0; zero findings |
| `PYTHONPATH=python python -m unittest discover -s tests/python -v` | Exit 0; 29 tests pass |
| `python -X utf8 scripts/validate_command_tree.py` | Exit 0; 48 commands |
| `python -X utf8 scripts/validate_operator_manual.py` | Exit 0; maintenance scripts and exported functions covered |
| `python -X utf8 scripts/verify_source_urls.py --out source-url-report.json` | Exit 0; 38/38 reachable; report written outside checkout in the actual run |
| `pwsh -NoProfile -File scripts/test-powershell-syntax.ps1` | Exit 0; 80 files, zero syntax findings |
| `pwsh -NoProfile -File scripts/test-service-state-fixture.ps1` | Exit 0; nine state/refusal/recovery assertions |
| `pwsh -NoProfile -File scripts/test-service-wrapper-fixture.ps1` | Exit 0; three real wrapper invocations with synthetic OS boundary |
| `pwsh -NoProfile -File scripts/test-powershell.ps1` | NOT_ASSESSED for Windows integration: attempted on Linux, fails unsupported WindowsPrincipal API after fixture checks |

The source URL report's destination in the actual command was a disposable
external file named `windows-final-source-urls.json`; no semantic claim depends
on its machine path. Tests use read-only repository mounts; fixture scratch
files live outside the checkout.

The service timeout fixture covers a returned transition that never reaches
the requested state. It does not test a service cmdlet that blocks without
returning: `TimeoutSeconds` bounds subsequent state polling, not the synchronous
`Start-Service`/`Stop-Service` call. That path and Windows recovery behavior
remain NOT_ASSESSED.

## Native installation

At clean commit `b2ddf50`, Codex 0.165.0 and Claude 2.1.312 both installed the
local `windows-admin@chwezi-windows-admin` plugin offline, exit 0. Commands:
`codex plugin marketplace add /engine --json`,
`codex plugin add windows-admin@chwezi-windows-admin --json`,
`codex plugin list --json`; equivalent Claude commands use `install` and
`details windows-admin@chwezi-windows-admin`. `/engine` is the disposable mount,
not a committed host binding. Claude's final inventory contains 20 intended
skills after the accidental README command was removed. Baseline Codex
`debug prompt-input` enumerated 20/20 canonical skill paths. These operations
perform no model call. Public directory approval, hooks and model behaviour
remain NOT_ASSESSED.

## Scope and remeasurement

The frozen baseline's first-rank result was subsequently measured as 19/19;
its original top-three gate alone did not report it. Expanded final fixtures
remain 100% first-rank. Three of 19 specialists now meet the three-positive and
two-owned-negative threshold, compared with zero. Two substantive worked plans
are linked in active skills; execution remains blocked where authority/labs are
missing. Scoped active-skill local-link checks remain clear; three router device
bindings were removed. The final cap recount includes Git objects and caches.
No cross-engine live execution, AD/GPO/SMB/IIS/Hyper-V/tenant, fleet canary,
production restore, Tier 3 or paid behavioural evaluation was assessed.

## Independent acceptance review

The read-only review of `52a2cdc..df3cc80` found the service refusal and
recovery outcomes conservatively represented: a failed restore remains Failed,
unknown after-state is not reported as verified, and fixture substitutions are
disclosed. The `TimeoutSeconds` description has been narrowed to its actual
scope: status polling after synchronous service calls return; a cmdlet that
hangs and its recovery remain NOT_ASSESSED.

The currentness review now cites Microsoft's specific KB5134137 notice for the
Server 2025 OOB update and keeps its CTL-limited applicability separate from
the October B baseline. This corrects citation scope only; target patch
applicability and support remain NOT_ASSESSED.

Marketplace inventory already supplies `os.walk(onerror=...)` and counts
directory symlinks without following them. Acceptance added regressions for
unreadable-subtree refusal and directory-symlink counting. The full Python suite
passes 31 tests (`PYTHONPATH=python python -X utf8 -m unittest discover -s tests/python -v`); engine validation passes with 20 skills, 468 checkout entries
and 291 package entries (`python -X utf8 scripts/validate_engine.py`); routing
passes 34/34 first-rank fixtures and 7/7 owned-negative checks
(`python -X utf8 scripts/routing_smoke_test.py`). The commands are lexical or
synthetic checks; they do not establish Windows service, domain, fleet or
public-marketplace behavior.

## Independent acceptance review

Luna/high reviewed the real cycle diff and kept additional traversal/symlink
regressions (`cf416fd`), the synchronous-cmdlet timeout limitation (`29c4958`)
and the scoped Microsoft update citation (`e87ef73`). Python unittest now passes
**31 tests**. The service timeout bounds polling after service cmdlets return;
it cannot guarantee cancellation of a hung synchronous OS call. That case
remains NOT_ASSESSED and requires an isolated Windows integration experiment.
At clean `29c4958`, root's final offline Codex prompt-input check discovers
20/20 skills with explicit Luna/high and a 10,000-token skills budget, no model
call. Subsequent changes are scoped currentness documentation only.
