# pywinauto core patterns (WPF worked example)

Full port of ECC's `windows-desktop-e2e` skill core pattern set, adapted for this
engine. The worked example below targets **WPF** specifically (best UIA support —
`x:Name` becomes AutomationId with zero extra work), per SKILL.md's decision to give
one framework a complete, faithful example rather than a shallow pass across all four.
For WinForms/Win32/MFC/Qt-specific testability setup, see `framework-notes.md` in this
same directory — only the identifier mechanism differs; every pattern below (locators,
waits, page objects, isolation tiers, CI) applies unchanged once AutomationId exists.

## WPF testability setup

```xml
<!-- XAML: x:Name becomes AutomationId automatically -->
<TextBox x:Name="usernameInput" />
<PasswordBox x:Name="passwordInput" />
<Button x:Name="btnLogin" Content="Login" />
<TextBlock x:Name="lblError" />
```

## Page Object Model layout

```
tests/
├── conftest.py          # app launch fixture, failure screenshot
├── pytest.ini
├── config.py
├── pages/
│   ├── __init__.py
│   ├── base_page.py     # locators, wait, screenshot helpers
│   ├── login_page.py
│   └── main_page.py
├── tests/
│   ├── __init__.py
│   ├── test_login.py
│   └── test_main_flow.py
└── artifacts/           # screenshots, videos, logs
```

### base_page.py

```python
import os, time
from pywinauto import Desktop
from config import ACTION_TIMEOUT, ARTIFACT_DIR

class BasePage:
    def __init__(self, window):
        self.window = window

    # --- Locators (priority order) ---

    def by_id(self, auto_id, **kw):
        """AutomationId — most stable. Use as first choice."""
        return self.window.child_window(auto_id=auto_id, **kw)

    def by_name(self, name, **kw):
        """Visible text / accessible name."""
        return self.window.child_window(title=name, **kw)

    def by_class(self, cls, index=0, **kw):
        """Control class + index — fragile, avoid if possible."""
        return self.window.child_window(class_name=cls, found_index=index, **kw)

    # --- Waits ---

    def wait_visible(self, spec, timeout=ACTION_TIMEOUT):
        spec.wait("visible", timeout=timeout)
        return spec

    def wait_gone(self, spec, timeout=ACTION_TIMEOUT):
        spec.wait_not("visible", timeout=timeout)
        return spec

    def wait_window(self, title, timeout=ACTION_TIMEOUT):
        """Wait for a new top-level window (dialogs, child windows)."""
        dlg = Desktop(backend="uia").window(title=title)
        dlg.wait("visible", timeout=timeout)
        return dlg

    def wait_until(self, fn, timeout=ACTION_TIMEOUT, interval=0.3):
        """Poll an arbitrary condition — use when UIA events are unreliable."""
        deadline = time.time() + timeout
        while time.time() < deadline:
            try:
                if fn():
                    return True
            except Exception:
                pass
            time.sleep(interval)
        raise TimeoutError(f"Condition not met within {timeout}s")

    # --- Actions ---

    def click(self, spec):
        self.wait_visible(spec)
        spec.click_input()

    def type_text(self, spec, text):
        self.wait_visible(spec)
        ctrl = spec.wrapper_object()
        try:
            ctrl.set_edit_text(text)
        except Exception as e:
            # Qt 5.x fallback: UIA Value Pattern may be incomplete
            import sys, pywinauto.keyboard as kb
            print(f"[windows-desktop-e2e] set_edit_text failed ({e}), using keyboard fallback", file=sys.stderr)
            ctrl.click_input()
            kb.send_keys("^a")
            kb.send_keys(text, with_spaces=True)

    def get_text(self, spec):
        ctrl = spec.wrapper_object()
        for attr in ("window_text", "get_value"):
            try:
                v = getattr(ctrl, attr)()
                if v:
                    return v
            except Exception:
                pass
        return ""

    # --- Artifacts ---

    def screenshot(self, name):
        os.makedirs(ARTIFACT_DIR, exist_ok=True)
        path = os.path.join(ARTIFACT_DIR, f"{name}.png")
        self.window.capture_as_image().save(path)
        return path
```

### login_page.py

```python
from pages.base_page import BasePage

class LoginPage(BasePage):
    @property
    def username(self): return self.by_id("usernameInput")

    @property
    def password(self): return self.by_id("passwordInput")

    @property
    def btn_login(self): return self.by_id("btnLogin")

    @property
    def error_label(self): return self.by_id("lblError")

    def login(self, user, pwd):
        self.type_text(self.username, user)
        self.type_text(self.password, pwd)
        self.click(self.btn_login)

    def login_ok(self, user, pwd, main_title="Main Window"):
        self.login(user, pwd)
        return self.wait_window(main_title)

    def login_fail(self, user, pwd):
        self.login(user, pwd)
        self.wait_visible(self.error_label)
        return self.get_text(self.error_label)
```

### config.py

```python
import os
APP_PATH          = os.environ.get("APP_PATH", "")           # set via env — no default path
MAIN_WINDOW_TITLE = os.environ.get("APP_TITLE", "")
LAUNCH_TIMEOUT    = int(os.environ.get("LAUNCH_TIMEOUT", "15"))
ACTION_TIMEOUT    = int(os.environ.get("ACTION_TIMEOUT", "10"))
ARTIFACT_DIR      = os.path.join(os.path.dirname(__file__), "artifacts")
```

### pytest.ini

```ini
[pytest]
testpaths = tests
markers =
    smoke: fast smoke tests for critical paths
    flaky: known-unstable tests
addopts = -v --tb=short --html=artifacts/report.html --self-contained-html
```

## Locator strategy

```
AutomationId  >  Name (text)  >  ClassName + index  >  XPath
  (stable)         (readable)       (fragile)           (last resort)
```

Inspect with Accessibility Insights → **Properties** pane → look for `AutomationId`
first.

```python
# Inspect at runtime — paste into a REPL to explore the tree
win.print_control_identifiers()
# or narrow scope:
win.child_window(auto_id="groupBox1").print_control_identifiers()
```

## Wait patterns

```python
# Wait for control to appear
page.wait_visible(page.by_id("statusLabel"))

# Wait for control to disappear (e.g. loading spinner)
page.wait_gone(page.by_id("spinnerOverlay"))

# Wait for a dialog to pop up
dlg = page.wait_window("Confirm Delete")

# Custom condition (e.g. text changes)
page.wait_until(lambda: page.get_text(page.by_id("lblStatus")) == "Ready")
```

**Never use `time.sleep()` as primary synchronization** — use `wait()` or `wait_until()`.

## Flaky test handling

```python
# Quarantine — equivalent to Playwright's test.fixme()
@pytest.mark.skip(reason="Flaky: animation race on slow CI. Issue #42")
def test_animated_transition(self, app): ...

# Skip in CI only
@pytest.mark.skipif(os.environ.get("CI") == "true", reason="Flaky in CI #43")
def test_heavy_load(self, app): ...
```

| Cause | Fix |
|-------|-----|
| Control not ready | Replace `time.sleep` with `wait_visible` |
| Window not focused | Add `win.set_focus()` before interactions |
| Animation in progress | `wait_until(lambda: not loading_indicator.exists())` |
| Dialog timing | `wait_window(title, timeout=15)` |
| CI display not ready | Set `DISPLAY` or use virtual desktop in CI |
| `set_edit_text` raises NotImplementedError | UIA ValuePattern missing (common on Qt 5.x) — fallback to `keyboard.send_keys` already in `type_text` |
| Control exists but `wait_visible` times out | Window minimised or off-screen — call `win.restore()` + `win.set_focus()` before waiting |

Add `pytest-timeout` to cap any single test: `pytest.ini` → `timeout = 60`,
`timeout_method = thread`. Note: `thread` method cannot kill Qt app subprocesses on
Windows — add `atexit.register(lambda: [p.kill() for p in
psutil.Process().children(recursive=True)])` in `conftest.py` to reap orphans.

## Test isolation — three tiers, use the lightest that satisfies the need

### Tier 1 — filesystem isolation (default, always use)

Each test gets its own `APPDATA` / `LOCALAPPDATA` / `TEMP` via `subprocess.Popen` and
`Application.connect()`. pytest's `tmp_path` fixture handles cleanup automatically.

```python
# conftest.py
import os, subprocess, pytest
from pywinauto import Application
from config import APP_PATH, APP_ARGS, APP_TITLE, LAUNCH_TIMEOUT, ACTION_TIMEOUT, ARTIFACT_DIR

@pytest.fixture(scope="function")
def app(request, tmp_path):
    """Fresh process + isolated user-data dirs per test."""
    if not APP_PATH:
        pytest.exit("APP_PATH not set", returncode=1)

    sandbox_env = os.environ.copy()
    sandbox_env["QT_ACCESSIBILITY"]  = "1"
    sandbox_env["APPDATA"]           = str(tmp_path / "AppData" / "Roaming")
    sandbox_env["LOCALAPPDATA"]      = str(tmp_path / "AppData" / "Local")
    sandbox_env["TEMP"] = sandbox_env["TMP"] = str(tmp_path / "Temp")
    for p in (sandbox_env["APPDATA"], sandbox_env["LOCALAPPDATA"], sandbox_env["TEMP"]):
        os.makedirs(p, exist_ok=True)

    if not APP_TITLE:
        pytest.exit("APP_TITLE environment variable is not set", returncode=1)

    import shlex  # handles quoted args with spaces; plain split() breaks on them
    proc = subprocess.Popen(
        [APP_PATH] + shlex.split(APP_ARGS),
        env=sandbox_env,
    )
    pw_app = Application(backend="uia").connect(process=proc.pid, timeout=LAUNCH_TIMEOUT)
    win    = pw_app.window(title=APP_TITLE)
    win.wait("visible", timeout=LAUNCH_TIMEOUT)
    yield win

    if getattr(getattr(request.node, "rep_call", None), "failed", False):
        os.makedirs(ARTIFACT_DIR, exist_ok=True)
        try:
            win.capture_as_image().save(
                os.path.join(ARTIFACT_DIR, f"FAIL_{request.node.name}.png")
            )
        except Exception:
            pass
    try:
        win.close()
        proc.wait(timeout=5)
    except Exception:
        proc.kill()
    # tmp_path is cleaned up automatically by pytest

@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    setattr(item, f"rep_{outcome.get_result().when}", outcome.get_result())
```

### Tier 2 — Windows Job Object (optional: process-lifetime containment)

Attach the process to a Job Object so it is **automatically terminated** when the test
fixture's job handle is GC'd. Also prevents the app from spawning child processes that
escape fixture cleanup.

> **Scope of isolation:** Job Objects do NOT virtualize filesystem access or block
> network traffic. File-write and network isolation require AppContainer, Windows
> Firewall rules, or Tier 3 (Windows Sandbox). Use Tier 2 only for process-lifetime and
> child-process containment.

```python
import ctypes, ctypes.wintypes as wt

def restrict_process(pid: int):
    """
    Attach the process to a Job Object that prevents it from:
    - spawning processes outside the job (LIMIT_KILL_ON_JOB_CLOSE)
    Does NOT block network — use Windows Firewall rules for that.
    """
    JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 0x00002000
    # Minimal rights: SET_QUOTA (0x0100) | TERMINATE (0x0001)
    PROCESS_SET_QUOTA_AND_TERMINATE    = 0x0101

    kernel32 = ctypes.windll.kernel32
    job   = kernel32.CreateJobObjectW(None, None)
    hproc = kernel32.OpenProcess(PROCESS_SET_QUOTA_AND_TERMINATE, False, pid)

    # Correct struct layout — LimitFlags is at offset +16, not +44
    class JOBOBJECT_BASIC_LIMIT_INFORMATION(ctypes.Structure):
        _fields_ = [
            ("PerProcessUserTimeLimit", wt.LARGE_INTEGER),
            ("PerJobUserTimeLimit",     wt.LARGE_INTEGER),
            ("LimitFlags",             wt.DWORD),
            ("MinimumWorkingSetSize",   ctypes.c_size_t),
            ("MaximumWorkingSetSize",   ctypes.c_size_t),
            ("ActiveProcessLimit",      wt.DWORD),
            ("Affinity",               ctypes.c_size_t),
            ("PriorityClass",          wt.DWORD),
            ("SchedulingClass",        wt.DWORD),
        ]

    info = JOBOBJECT_BASIC_LIMIT_INFORMATION()
    info.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
    ok = kernel32.SetInformationJobObject(job, 2, ctypes.byref(info), ctypes.sizeof(info))
    if not ok:
        raise ctypes.WinError()
    kernel32.AssignProcessToJobObject(job, hproc)
    kernel32.CloseHandle(hproc)
    return job  # keep alive — job closes (kills proc) when GC'd

# After proc = subprocess.Popen(...):  job = restrict_process(proc.pid)
```

### Tier 3 — Windows Sandbox (CI full-OS isolation)

When a clean Windows image is needed per run (no leftover registry keys, no shared GPU
state, true isolation), run the **entire test suite** inside Windows Sandbox.
Requirement: Windows 10/11 Pro or Enterprise, Virtualization enabled.

```xml
<!-- e2e-sandbox.wsb -->
<Configuration>
  <MappedFolders>
    <MappedFolder>
      <HostFolder>C:\path\to\your\build\Release</HostFolder>
      <SandboxFolder>C:\app</SandboxFolder>
      <ReadOnly>true</ReadOnly>
    </MappedFolder>
    <MappedFolder>
      <HostFolder>C:\path\to\your\e2e_test</HostFolder>
      <SandboxFolder>C:\e2e_test</SandboxFolder>
      <ReadOnly>false</ReadOnly>
    </MappedFolder>
  </MappedFolders>
  <LogonCommand>
    <Command>powershell -Command "
      winget install --id Python.Python.3.11 --silent --accept-package-agreements;
      $env:PATH += ';' + $env:LOCALAPPDATA + '\Programs\Python\Python311\Scripts';
      cd C:\e2e_test;
      pip install -r requirements.txt;
      pytest tests\ -v
    "</Command>
  </LogonCommand>
</Configuration>
```

Launch: `WindowsSandbox.exe e2e-sandbox.wsb`. pywinauto and the app both run **inside**
the sandbox (same session required); artifacts write back to the host via the mapped
folder.

| Tier | Isolation | Setup cost | Works on CI | Use when |
|------|-----------|-----------|-------------|----------|
| 1 — `tmp_path` env redirect | Filesystem | Zero | Always | Default for all tests |
| 2 — Job Object | Process tree | Low | Always | Prevent child-process escape |
| 3 — Windows Sandbox | Full OS | Medium | Needs Pro/Enterprise image | Nightly clean-room runs |

## CI/CD integration

```yaml
# .github/workflows/e2e-desktop.yml
name: Desktop E2E
on: [push, pull_request]

jobs:
  e2e:
    runs-on: windows-latest   # real GUI environment, no Xvfb needed
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with: { python-version: "3.11" }

      - name: Install deps
        run: pip install pywinauto pytest pytest-html Pillow

      - name: Build app
        run: cmake --build build --config Release  # adjust to your build system

      - name: Run E2E
        env:
          APP_PATH: ${{ github.workspace }}\build\Release\MyApp.exe
          APP_TITLE: "My Application"
          CI: "true"
        run: pytest tests/ --html=artifacts/report.html --self-contained-html --junitxml=artifacts/results.xml -v

      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: e2e-artifacts
          path: artifacts/
          retention-days: 14
```

## Per-step trace (opt-in, off by default)

The default failure screenshot is often too thin for diagnosing flaky tests. Enable
only when reproducing a flaky case:

```bash
E2E_TRACE=1 pytest tests/test_login.py -v
# Include typed text in the JSONL log (DO NOT use on tests that type credentials/PII):
E2E_TRACE=1 E2E_TRACE_INCLUDE_TEXT=1 pytest ...
```

Patch into `BasePage`:

```python
import os, json, time
TRACE_ENABLED      = os.environ.get("E2E_TRACE") == "1"
TRACE_INCLUDE_TEXT = os.environ.get("E2E_TRACE_INCLUDE_TEXT") == "1"

class BasePage:
    _step = 0

    def _trace(self, action, spec=None, text=None):
        if not TRACE_ENABLED:
            return
        BasePage._step += 1
        idx = f"{BasePage._step:03d}"
        os.makedirs(ARTIFACT_DIR, exist_ok=True)
        try:
            self.window.capture_as_image().save(
                os.path.join(ARTIFACT_DIR, f"step_{idx}_{action}.png"))
        except Exception:
            pass  # capture failure must not break the test
        rec = {
            "ts": time.time(), "step": BasePage._step, "action": action,
            "locator": getattr(spec, "criteria", None),
            "text": text if TRACE_INCLUDE_TEXT else ("<redacted>" if text else None),
        }
        with open(os.path.join(ARTIFACT_DIR, "trace.jsonl"), "a") as f:
            f.write(json.dumps(rec) + "\n")
```

Caveats: PII/credentials stay `<redacted>` by default — never flip
`E2E_TRACE_INCLUDE_TEXT=1` on login/payment flows. Overhead is ~50–200ms per action
plus one PNG per step — don't enable on the default CI matrix, only on a dedicated
flake-repro job. Clear the artifact directory before reruns and use per-worker artifact
dirs for parallel tests. Actions performed outside `BasePage` (raw pywinauto calls in
test code) are not traced.

## Fallback: screenshot mode (last resort only)

When a control is not reachable via UIA (self-drawn, third-party, game engine):

```bash
pip install pyautogui Pillow opencv-python
```

```python
import pyautogui, cv2, numpy as np
from PIL import Image

def find_image_on_screen(template_path, confidence=0.85):
    """Locate a template image on screen. Returns (x, y) center or None."""
    screen   = np.array(pyautogui.screenshot())
    template = np.array(Image.open(template_path))
    result   = cv2.matchTemplate(
        cv2.cvtColor(screen, cv2.COLOR_RGB2BGR),
        cv2.cvtColor(template, cv2.COLOR_RGB2BGR),
        cv2.TM_CCOEFF_NORMED,
    )
    _, max_val, _, max_loc = cv2.minMaxLoc(result)
    if max_val >= confidence:
        h, w = template.shape[:2]
        return max_loc[0] + w // 2, max_loc[1] + h // 2
    return None

def click_image(template_path, confidence=0.85):
    pos = find_image_on_screen(template_path, confidence)
    if pos is None:
        raise RuntimeError(f"Image not found on screen: {template_path}")
    pyautogui.click(*pos)
```

DPI/scaling rules (screenshot mode only): capture templates at the same scale as the
target machine — don't rescue a mismatch with `PIL.Image.resize`, `cv2.matchTemplate`
is fragile against resampling artefacts. Pin CI display scaling (e.g.
`Set-DisplayResolution 1920 1080 -Force`, disable per-monitor DPI scaling). Record
`GetDpiForWindow(hwnd) / 96` alongside every artefact. Process-level DPI awareness can
conflict with Qt's own DPI handling — prefer same-scale templates + CI pin over
flipping process-wide DPI mode.

## Anti-patterns (with fixes)

```python
# BAD: fixed sleep
time.sleep(3)
page.click(page.by_id("btnSubmit"))

# GOOD: condition wait
page.wait_visible(page.by_id("btnSubmit"))
page.click(page.by_id("btnSubmit"))
```

```python
# BAD: brittle class+index locator as primary strategy
page.by_class("Edit", index=2).type_keys("hello")

# GOOD: AutomationId
page.by_id("usernameInput").set_edit_text("hello")
```

```python
# BAD: assert on pixel coordinates
assert btn.rectangle().left == 120

# GOOD: assert on content / state
assert page.get_text(page.by_id("lblStatus")) == "Logged in"
assert page.by_id("btnLogout").is_enabled()
```

```python
# BAD: share app instance across all tests (state leaks)
@pytest.fixture(scope="session")
def app(): ...

# GOOD: fresh process per test (or per class at most)
@pytest.fixture(scope="function")
def app(): ...
```

## Running tests

```bash
pytest tests/ -v                              # all tests
pytest tests/ -m smoke -v                      # smoke only
pytest tests/test_login.py -v                  # specific file
APP_PATH="C:\build\Release\MyApp.exe" APP_TITLE="MyApp" pytest tests/ -v
pip install pytest-repeat
pytest tests/test_login.py --count=5 -v        # detect flaky tests
```
