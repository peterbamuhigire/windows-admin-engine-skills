---
name: windows-portability-doctrine
description: Use when any agent tooling, installer, or hook claims to be "cross-platform" and will run on Windows — Git Bash/MSYS2 path handling, symlink-chain resolution, background-process survival, and line-ending mismatches. This engine owns this doctrine for the whole Chwezi estate, not only for itself.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
  origin: original synthesis for this engine, grounded in documented real incidents — not an ECC import. Sources cited inline per claim.
---

# Windows Portability Doctrine

<!-- dual-compat-start -->

## Use when

- Any engine, installer, or hook in the Chwezi estate claims "cross-platform" support
  and will actually be exercised on a Windows host.
- A shell script invokes a native binary (Node, Python) from Git Bash/MSYS2.
- A tool spawns a background/long-lived process from a Claude Code hook on Windows.
- An installer resolves its own script path through a symlink or npm bin shim.
- Reviewing another engine's `install.sh`/`install.ps1` for real portability, not just
  the absence of GNU-only flags.

## Do not use when

- The work is Windows-native admin work (AD, fleet, storage) — that is this engine's
  other 18 skills, not this one. This skill is specifically about **tooling
  correctness on Windows**, not Windows administration.
- A claim only needs static review (no GNU-only flags, LF line endings) — that is a
  necessary but insufficient check; this skill's stop condition (below) still applies:
  a portability claim is not "done" until actually run on Windows.

## Inputs

- The artefact under review: `install.sh`, `install.ps1`, hook script, npm bin shim,
  or background-process launcher, with its repository and commit.
- The claimed support matrix (native Windows via Git Bash/MSYS2, PowerShell 5.1,
  PowerShell 7, WSL2, Linux, macOS).
- Access, or its absence, to a real Windows host on which the artefact can be run.

## Platform and privilege boundary

Applies to Windows 10/11 and Windows Server hosts running Git for Windows (MSYS2
runtime), Windows PowerShell 5.1, PowerShell 7, or WSL2. The audit itself is R0
(read-only review and a disposable run in a user profile). Running an installer
against a shared or production profile is at least R1 and needs the owning engine's
approval; never run it elevated to "make it work".

## Why this engine owns this doctrine

Every other Chwezi engine writes `install.sh` and `install.ps1` and asserts
cross-platform behaviour. Only this engine has a standing reason to actually run,
diagnose, and fix things on a real Windows host as its core subject matter. The
incidents below were found by *running* things on Windows, not by reading code — that
is the discipline this skill exists to generalise.

## Core doctrine: a cross-platform claim is untested until run on the target OS

The single rule underneath every pattern below: static review (no `rm -rf`, no
GNU-only sed flags, LF line endings) catches syntax-level non-portability. It does
**not** catch semantic non-portability — code that parses fine on Windows and does the
wrong thing anyway. Every incident in this file was exactly that: syntactically valid,
semantically broken, and invisible without actually executing it on Windows.

## Documented incidents this doctrine is grounded in

### 1. Git Bash / MSYS2 path-doubling (POSIX-to-Windows path conversion)

**Symptom:** a POSIX-looking path passed to a native Windows binary (Node.js) comes
out doubled and invalid, e.g. `G:\g\projects\...` instead of the real path.

**Mechanism:** MSYS2/Git Bash auto-converts POSIX-style path arguments before handing
them to a native (non-MSYS) executable. When the script has already resolved an
absolute path itself (e.g. via `cd "$(dirname "$SCRIPT_PATH")" && pwd`), MSYS2's
auto-conversion layer applies a *second* transformation on top of the already-resolved
path, corrupting it.

**Fix:** detect `cygpath` and convert explicitly before the native binary sees the
path, falling through to the raw path when `cygpath` is unavailable (e.g. real Linux
or macOS):

```bash
if command -v cygpath &>/dev/null; then
    NODE_SCRIPT="$(cygpath -w "$SCRIPT_DIR/scripts/install-apply.js")"
else
    NODE_SCRIPT="$SCRIPT_DIR/scripts/install-apply.js"
fi
exec node "$NODE_SCRIPT" "$@"
```

**Sources:**
- ECC `install.sh` (`C:\Users\Peter\Downloads\ECC-main\install.sh`, lines 27-32), comment:
  "On MSYS2/Git Bash, convert the POSIX path to a Windows path so Node.js (a native
  Windows binary) receives a valid path instead of a doubled one like
  `G:\g\projects\...`".
- This Kaizen operation's own infrastructure, independently: `chwezi-engine-agents`
  `scripts/install.sh.template` (`C:\wamp64\www\chwezi-engine-agents\scripts\install.sh.template`,
  lines 5-9, 30-32) — written and fixed during this operation's own work, citing the
  ECC precedent explicitly in its own comment ("This is the same fix documented in
  ECC's install.sh"). This confirms the bug is a real, independently-rediscovered
  MSYS2 behaviour, not a one-off ECC quirk.

**Rule:** any `install.sh` that shells out to a native Windows binary (Node, a
compiled tool) with a path argument built by the shell script itself MUST guard with
`command -v cygpath` and convert. Do not assume the interpreter/runtime "handles
Windows paths fine" — Node does, but only if the *shell* handed it a real one first.

### 2. Symlink-chain resolution for self-locating scripts

**Symptom:** an installer invoked through an npm bin shim (which is often a symlink,
including on Windows via npm's `.cmd`/junction shims) resolves its own directory
incorrectly, because a naive `dirname "$0"` returns the symlink's directory, not the
real script's.

**Fix:** walk the symlink chain to the real file before resolving the directory:

```bash
SCRIPT_PATH="$0"
while [ -L "$SCRIPT_PATH" ]; do
    link_dir="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
    SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
    [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$link_dir/$SCRIPT_PATH"
done
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
```

**Sources:** ECC `install.sh` lines 9-15; `chwezi-engine-agents`
`scripts/install.sh.template` lines 14-20 (same pattern, vendored and confirmed
during this operation).

**Rule:** any self-locating installer script must resolve through the full symlink
chain, not a single `readlink`/`dirname` call, and must handle a relative link target
(`[[ "$SCRIPT_PATH" != /* ]]`) by rejoining it against the link's own directory, not
the caller's cwd.

### 3. Background/long-lived processes spawned from a hook do not survive on native Windows

**Symptom:** a background observer/watcher process spawned from a Claude Code hook
starts and *reports* success on native Windows (Git Bash/MSYS2), but no analysis or
observation ever actually runs — the feature is a silent no-op.

**Mechanism:** the spawning hook process exits after the tool call completes; on
Windows the child is attached to a Job Object tied to the parent, and when that Job
Object closes, the child is killed along with it — unlike POSIX `nohup`/double-fork
detachment, which lets a child outlive its parent shell.

**Fix documented upstream:** none within Git Bash/MSYS2 itself — the feature is scoped
to require WSL2, Linux, or macOS, and the tool detects repeated non-survival and warns
explicitly rather than pretending the feature works.

**Source:** ECC `continuous-learning-v2` skill
(`C:\Users\Peter\Downloads\ECC-main\skills\continuous-learning-v2\SKILL.md`, "Observer
platform support" section): *"The background observer requires WSL2, Linux, or macOS.
On native Windows (Git Bash / MSYS2) it starts and reports success, but the process is
killed when the spawning hook exits and its Job Object closes, so no analysis ever
runs... (see issue #2489)."* The same file documents a corroborating-evidence pattern
worth reusing: `observe.sh` detects the non-survival on the *next* hook invocation and
logs an explanatory warning after `ECC_OBSERVER_NOSURVIVE_WARN_AFTER` (default 3)
consecutive failures, rather than either crashing loudly or staying silent forever.

**Rule:** never assume a spawned background process on native Windows outlives its
parent hook invocation. Either (a) scope the feature to WSL2/Linux/macOS explicitly
and say so in the skill's own "when NOT to use" section, or (b) if the feature must
work on native Windows, use a Windows-native detachment mechanism (a separate Job
Object with `JOB_OBJECT_LIMIT_BREAKAWAY_OK`, or `schtasks`/a Windows service) — not a
POSIX-style backgrounding idiom that silently degrades to a no-op.

### 4. CRLF / line-ending corruption of shell scripts distributed through Windows tooling

**Symptom:** `spawn UNKNOWN` or similar cryptic spawn failures when a `.sh` script
vendored or edited on Windows picks up CRLF line endings; the shebang line
(`#!/usr/bin/env bash`) becomes `#!/usr/bin/env bash\r`, which most interpreters fail
to resolve.

**Fix:** enforce LF-only line endings on every distributed shell script (`.gitattributes`
`* text eol=lf` for `*.sh`, or a `dos2unix` pass as part of vendoring/packaging), and
verify after any edit made through a Windows-native editor or PowerShell `Set-Content`
(which defaults to CRLF).

**Source:** ECC `TROUBLESHOOTING.md`
(`C:\Users\Peter\Downloads\ECC-main\TROUBLESHOOTING.md`, "spawn UNKNOWN" section):
*"Windows-specific: Ensure scripts use correct line endings... Convert CRLF to LF...
`find ~/.claude/plugins -name "*.sh" -exec dos2unix {} \;`"*.

**Rule:** this session's own Wave 1 work already applied "LF-only, POSIX-portable
bash, no GNU-only flags" as a static check (per
`13-kaizen-execution-status.md`) — this doctrine file makes that check a named,
citable rule rather than an unwritten convention, and extends it: CRLF corruption can
be reintroduced by any *subsequent* Windows-native edit, so it is a per-edit
discipline, not a one-time install-time fix.

## Workflow

Auditing another engine's "cross-platform" claim:

1. Read the actual `install.sh` / `install.ps1`, not just their existence. Check for
   the `cygpath` guard (incident 1) if the script shells out to a native binary with a
   self-resolved path.
2. Check symlink-chain resolution (incident 2) if the script locates itself via `$0`.
3. If the tool spawns anything backgrounded or long-lived from a hook, check whether it
   is scoped away from native Windows or uses a Windows-native detachment mechanism
   (incident 3).
4. Confirm LF line endings on every `.sh` file touched since the last audit (incident 4).
5. **Then run it on a real Windows host** — Git Bash at minimum, PowerShell if the
   engine ships a `.ps1`. A static pass through steps 1-4 is necessary, not
   sufficient; state explicitly whether step 5 was actually done, per this engine's
   own `rules/common/core.md` ("Missing evidence is `NOT_ASSESSED`, never inferred
   success").

## Mutation, verification, and recovery

The audit reads code and runs the artefact in a disposable user profile or VM. A fix
to another engine's script is a change to that engine and follows its own change
discipline. Verification is an observed run on each claimed shell (Git Bash, Windows
PowerShell 5.1, PowerShell 7) with exit code, resolved paths, and resulting files
recorded; exit code 0 alone is not proof. Recovery: remove whatever the trial run
installed (use the installer's own uninstall path where one exists) and restore the
profile snapshot if it was used.

## Capability contract and degraded mode

Full mode: repository read access plus a Windows host where the artefact can be run.
Degraded mode: static review only (steps 1-4 of the workflow). Report every incident
check as passed, failed, or `NOT_ASSESSED`, and mark the portability claim as a
whole `NOT_ASSESSED` until step 5 has actually been done.

## Outputs

A portability finding per artefact: the four incident checks with evidence (file and
line), the shells and OS builds actually exercised, observed results, required fixes,
and an overall verdict of `PORTABLE_VERIFIED`, `DEFECTS_FOUND`, or `NOT_ASSESSED`.

## Decision rules

| Condition | Action |
|---|---|
| Shell script passes a self-resolved path to a native binary | Require the `cygpath -w` guard (incident 1) |
| Script locates itself through `$0` and may be invoked via a shim | Require the full symlink-chain walk (incident 2) |
| Hook spawns a background or long-lived process | Scope it away from native Windows, or prove survival with a Windows-native mechanism (incident 3) |
| Any `.sh` was edited with a Windows-native tool | Re-check LF endings; enforce with `.gitattributes` (incident 4) |
| A `.ps1` must run on stock Windows | Test under Windows PowerShell 5.1 as well as PowerShell 7 |
| No Windows host available | Deliver the static findings and mark the claim `NOT_ASSESSED` |

## Stop conditions

Stop and state `NOT_ASSESSED` rather than claim portability when: the claim has only
been reviewed statically and no Windows host was available to run it; a background
process's survival behaviour on Windows has not been directly observed (started, then
independently confirmed still running after the parent exits); or a script was edited
through a Windows-native tool and line endings were not re-verified afterward.

## Quality standards

No "should work on Windows" claims without an actual run. No POSIX-only backgrounding
idiom presented as cross-platform without the Job Object caveat stated. No installer
that resolves its own path without both the symlink-chain walk and the `cygpath`
guard, if it shells out to a native binary.

## Anti-patterns

- Asserting "cross-platform, tested" from code review alone. Fix: state what was
  actually run, on what OS, per the estate's verification rule.
- Naive `dirname "$0"` in an installer meant to be invoked via an npm bin shim. Fix:
  walk the full symlink chain (incident 2).
- A background hook-spawned watcher with no platform scoping statement. Fix: either
  scope it out of native Windows explicitly, or prove survival with a Windows-native
  detachment mechanism.
- Editing a vendored `.sh` file with a Windows-native tool and skipping a line-ending
  check afterward. Fix: re-verify LF endings as part of the edit, not just at initial
  vendoring time.

## References

- [`rules/common/core.md`](../../../rules/common/core.md) — the estate verification rule this doctrine applies.
- [`docs/safety-model.md`](../../../docs/safety-model.md) — risk classes for trial runs of installers.
- Microsoft Job Objects documentation (source `MS-JOB-OBJECTS`): https://learn.microsoft.com/en-us/windows/win32/procthread/job-objects
- Windows PowerShell 5.1 vs PowerShell 7 differences (source `MS-POWERSHELL`).

## Related skills

- `windows-development-workstation` — provisions the toolchain (Git Bash, Node,
  Python) this doctrine assumes exists on the host being audited.
- `windows-desktop-e2e-testing` — a consumer of this doctrine's discipline (its own
  test harness must itself be verified on Windows, not just the app under test).

<!-- dual-compat-end -->
