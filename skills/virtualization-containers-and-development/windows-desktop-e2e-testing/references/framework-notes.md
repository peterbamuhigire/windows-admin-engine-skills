# Non-WPF framework testability notes

`pywinauto-core-patterns.md` gives a complete worked example for WPF. Every locator,
wait, page-object, isolation-tier, and CI pattern there applies unchanged to the other
frameworks below — the only thing that differs per framework is **how you get a
stable AutomationId onto a control in the first place**. This file is deliberately a
pointer, not a full re-derivation, per this skill's scope decision (see SKILL.md
frontmatter `metadata.origin`).

## WinForms

```csharp
// Set in designer or code
usernameInput.AccessibleName = "usernameInput";
passwordInput.AccessibleName = "passwordInput";
btnLogin.AccessibleName = "btnLogin";
lblError.AccessibleName = "lblError";
```

`AccessibleName` becomes the AutomationId pywinauto's `by_id()` matches on.

## Win32 / MFC

Control resource IDs in the `.rc` file are exposed as AutomationId strings (e.g.
`IDC_EDIT_USERNAME` → AutomationId `"1001"`). Prefer `SetWindowText` for the Name
property; add IAccessible for richer support. UIA quality here is "Fair" — text
matching (`by_name`) is common as a fallback when the numeric ID isn't stable across
resource-file edits.

## Qt (5.x and 6.x)

Qt 6.x enables accessibility by default — no extra setup. Qt 5.x (especially
5.7–5.14) disables it in some builds; set the environment variable **before**
launching:

```python
# conftest.py — add at module top
import os
os.environ["QT_ACCESSIBILITY"] = "1"
```

Or in CI:

```yaml
env:
  QT_ACCESSIBILITY: "1"
```

Add stable identifiers to Qt widgets on both `objectName` and `accessibleName` (the
latter becomes the UIA `Name` property):

```cpp
void setTestId(QWidget* w, const char* id) {
    w->setObjectName(id);
    w->setAccessibleName(id);
}

// In your dialog constructor:
setTestId(ui->usernameEdit, "usernameInput");
setTestId(ui->passwordEdit, "passwordInput");
setTestId(ui->loginButton,  "btnLogin");
setTestId(ui->errorLabel,   "lblError");
```

Centralise all IDs in a header to avoid typos:

```cpp
// test_ids.h
#define TID_USERNAME   "usernameInput"
#define TID_PASSWORD   "passwordInput"
#define TID_BTN_LOGIN  "btnLogin"
#define TID_LBL_ERROR  "lblError"
```

### Qt-specific quirks worth knowing before you hit them

- **QComboBox** — the dropdown is a separate top-level window; class name varies by
  Qt version (`Qt5QWindowIcon` vs `Qt6QWindowIcon`), verify with Accessibility
  Insights:
  ```python
  popup = Desktop(backend="uia").window(class_name_re="Qt[56]QWindowIcon")
  popup.wait("visible", timeout=5)
  popup.child_window(title=item_text).click_input()
  ```
- **QMessageBox / QDialog** — also separate top-level windows; use `wait_window(title)`
  then `child_window(title="OK").click_input()`.
- **QTableWidget / QTableView** — `table.cell(row=0, column=1).window_text()`.
- **Self-drawn controls** (`paintEvent`-only, `QGraphicsView`, `QOpenGLWidget`) — UIA
  cannot see their internals; use the screenshot fallback in
  `pywinauto-core-patterns.md`.

## UWP / WinUI 3

Full Microsoft UIA support (5/5) — treated the same as WPF in practice; no
Qt-style environment flag or WinForms-style `AccessibleName` shim needed.
