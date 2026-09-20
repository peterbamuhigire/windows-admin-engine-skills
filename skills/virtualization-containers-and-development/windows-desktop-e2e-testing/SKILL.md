---
name: windows-desktop-e2e-testing
description: Use when setting up or diagnosing end-to-end tests for a Windows native desktop application (WPF, WinForms, Win32/MFC, Qt) via pywinauto and Windows UI Automation; use windows-development-workstation for toolchain provisioning, not test authoring.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
  origin: adapted from ECC (everything-claude-code) skills/windows-desktop-e2e, full port of the core pywinauto/UIA pattern set plus a complete WPF worked example; other frameworks (WinForms, Win32/MFC, Qt) are scoped to their testability-setup differences only — see references/framework-notes.md for what was deliberately left as a pointer rather than fully re-derived.
---

# Windows Desktop E2E Testing

<!-- dual-compat-start -->

## Use when

- Standing up an E2E test suite for a Windows native (non-web, non-Electron) desktop app.
- Diagnosing flaky or failing UI Automation (UIA) tests on Windows.
- Adding testability (AutomationId / AccessibleName) to an app that has none.
- Wiring desktop E2E into a `windows-latest` GitHub Actions job.

## Do not use when

- The app is a web app → use a browser-automation (Playwright/Selenium) skill instead.
- The app is Electron/CEF/WebView2 → the UI is an embedded browser; automate the HTML layer, not UIA.
- The app is mobile → use platform-specific tooling (UIAutomator, XCUITest), not this skill.
- You need workstation/toolchain provisioning (installing Python, pywinauto, ffmpeg) →
  that is `windows-development-workstation`'s job; this skill assumes the toolchain exists.

## Inputs

App under test (path + launch args), target framework (WPF/WinForms/Win32/MFC/Qt +
version), main window title, whether AutomationId/AccessibleName is already set on
controls, CI target (`windows-latest` or self-hosted), and the isolation tier required
(filesystem-only, process-tree containment, or full-OS sandbox — see Workflow step 4).

## Platform and privilege boundary

This is R0/R1 work: it drives a UI with a standard user token and reads accessibility
properties. It does not touch AD, fleet policy, or system configuration. The one
R2-adjacent case is Tier 3 isolation (Windows Sandbox), which requires
Virtualization enabled and a Pro/Enterprise image — treat enabling that feature on a
managed endpoint as its own change with its own rollback, not part of this skill.

## Core concept — UI Automation is the substrate

Every path in this skill goes through the same chain, and every framework difference
is just "how good is that framework's UIA provider":

```
pytest test → pywinauto (UIA backend) → Windows UI Automation API (built into Windows)
                                            → app's UIA provider (framework-specific)
                                                → the running .exe
```

UIA quality by framework (drives how much of the Locator Strategy below you can rely
on vs. fall back from):

| Framework | AutomationId | Reliability |
|---|---|---|
| WPF | `x:Name` → AutomationId automatically | Excellent |
| UWP / WinUI 3 | Full Microsoft support | Excellent |
| Qt 6.x | Accessibility on by default | Excellent |
| WinForms | `AccessibleName` = AutomationId | Good |
| Qt 5.15+ | Needs `QT_ACCESSIBILITY=1` | Good |
| Qt 5.7–5.14 | Needs `QT_ACCESSIBILITY=1`, manual `objectName` | Fair |
| Win32 / MFC | Control resource IDs only; text matching common | Fair |

## Workflow

1. **Verify UIA is reachable before writing a single test.** `pip install pywinauto
   pytest pytest-html Pillow pytest-timeout`, then confirm with `Desktop(backend="uia").
   windows()`. Install **Accessibility Insights for Windows** (free, Microsoft) — it is
   the DevTools-equivalent inspector; use it to find each control's `AutomationId`
   before guessing a locator.

2. **Add stable identifiers to every interactive control before automating it.** For
   WPF, `x:Name` in XAML becomes the AutomationId with no extra work — see
   `references/pywinauto-core-patterns.md` for the full worked WPF login example. For
   WinForms, Win32/MFC, and Qt, the identifier mechanism differs; see
   `references/framework-notes.md` for the short per-framework recipe rather than
   re-deriving it here.

3. **Build the Page Object Model and locate by priority order, not convenience.**
   `AutomationId > Name (text) > ClassName+index > XPath` — stable to fragile, in that
   order. The full `BasePage` (locators, waits, actions, screenshot-on-failure) and a
   `LoginPage` example are in `references/pywinauto-core-patterns.md`. Never use
   `time.sleep()` as primary synchronization — use `wait_visible`/`wait_until`.

4. **Choose the lightest isolation tier that satisfies the need, and state which one
   you chose.** Tier 1 (per-test `APPDATA`/`LOCALAPPDATA`/`TEMP` redirect via
   `tmp_path`) is the default for every test, at zero cost — always use it. Tier 2
   (Windows Job Object) adds process-tree containment (child processes can't escape
   fixture cleanup) but does **not** isolate filesystem or network. Tier 3 (Windows
   Sandbox) is full-OS isolation for nightly clean-room runs only — it needs
   Virtualization enabled and Pro/Enterprise. Full code for all three tiers is in
   `references/pywinauto-core-patterns.md`.

5. **Wire CI on `windows-latest`, not a Linux runner with a workaround.** UIA needs a
   real Windows GUI session — there is no Xvfb equivalent. Full workflow YAML is in
   `references/pywinauto-core-patterns.md`.

6. **When a control is genuinely unreachable via UIA** (self-drawn `paintEvent`-only
   widgets, `QGraphicsView`, `QOpenGLWidget`, game engines), fall back to screenshot
   matching (`pyautogui` + `cv2.matchTemplate`) — but only as a last resort, and never
   as the primary strategy. DPI/display-scaling mismatches break screenshot matching
   silently; pin CI display scaling and record the capture DPI alongside every
   artifact. See `references/pywinauto-core-patterns.md` for the fallback helpers and
   the three hard DPI rules.

## Mutation, verification, and recovery

Running a desktop E2E suite launches and kills real processes and can write to real
`APPDATA`/registry state if isolation is skipped. Verify the fixture actually cleans
up: a failed `win.close()` must fall through to `proc.kill()` (Tier 1) or rely on the
Job Object's `LIMIT_KILL_ON_JOB_CLOSE` (Tier 2), never leave an orphaned process.
Rollback path: kill any process this skill's fixtures launched (`proc.kill()` /
job-object teardown); Tier 1's `tmp_path` isolation means no host `APPDATA` state needs
reverting when it was used correctly — if it was skipped, state that explicitly rather
than assuming the app touched nothing.

## Stop conditions

Stop and ask rather than guess when: `APP_PATH` or the main window title is not
supplied (this skill sets no default path — an unset `APP_PATH` must fail the fixture,
not silently no-op); the target framework is unclear and AutomationId quality can't be
assessed; a test needs to type credentials/PII and step-tracing
(`E2E_TRACE_INCLUDE_TEXT=1`) is requested for that flow — refuse and use redacted
tracing instead; or Tier 3 (Windows Sandbox) is requested on a host where
Virtualization/Pro-Enterprise status hasn't been confirmed.

## Capability contract and degraded mode

Read-only: inspecting the UIA tree, running existing tests, reading CI logs. Mutation
(launching/killing processes, writing test artifacts, adding AutomationIds to source)
needs the app's source or binary in hand and a confirmed launch command; without it,
produce the Page Object Model / fixture plan and mark execution `NOT_ASSESSED` rather
than claim a test passed that was never run.

## Outputs

Page Object Model (`base_page.py`, per-screen page classes), pytest fixtures with the
chosen isolation tier, `pytest.ini`, CI workflow, and — for any flaky-test diagnosis —
the per-step JSONL trace with text redacted by default. State which isolation tier was
used and why.

## Decision rules

| Condition | Action |
|---|---|
| Control has no AutomationId and framework is WPF/WinForms | Add one before writing the test — cheapest fix available |
| Framework is Qt 5.7–5.14 | Set `QT_ACCESSIBILITY=1` before launch, or UIA will not see the tree |
| Control genuinely unreachable via UIA | Fall back to screenshot matching, pin CI display scaling, record DPI |
| Test needs to survive parallel/rerun | Use per-worker artifact dirs; don't share a class-level trace counter across workers |
| `set_edit_text` raises `NotImplementedError` | UIA ValuePattern missing (common on Qt 5.x) — fall back to `keyboard.send_keys` |
| Need clean-room isolation for CI | Use Tier 3 (Windows Sandbox), not process-level DPI/env hacks on the default runner |

## Quality standards

No fixed `time.sleep()` as primary synchronization. No shared/session-scoped app
fixture across tests (state leaks). No credential/PII text in trace artifacts unless
explicitly and narrowly opted in. No asserting on pixel coordinates — assert on
content/state (`get_text`, `is_enabled`). AutomationId preferred over class+index over
XPath, in that order, every time a locator is written.

## Anti-patterns

- Fixed `time.sleep()` before an action. Fix: `wait_visible`/`wait_until` on the real condition.
- Brittle `by_class(..., index=N)` as a primary locator. Fix: add an AutomationId and use `by_id`.
- Session-scoped `app` fixture shared across tests. Fix: function-scoped, fresh process per test.
- Asserting on `rectangle().left == 120`. Fix: assert on visible text or control state.
- Enabling `E2E_TRACE_INCLUDE_TEXT=1` on a login/payment flow "just to debug once." Fix: redacted tracing stays on; never flip it for a credential flow.

## Related skills

- `windows-development-workstation` — provisions the Python/pywinauto/ffmpeg toolchain this skill assumes already exists.
- `windows-portability-doctrine` — the cross-cutting doctrine for tooling correctness on Windows (path handling, shell differences); consult it if the test harness itself misbehaves on Windows rather than the app under test.

<!-- dual-compat-end -->
