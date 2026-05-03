# PowerShell GUI

The native PowerShell WPF GUI provides a full-featured alternative to the web UI — no Node.js, no browser, just a single command.

```powershell
.\Start-EntraGoat.ps1
```

<!-- Screenshot: PS GUI home page -->
![PowerShell GUI Home](../screenshots/ps-gui-home.png)

## Features

| Feature | Description |
|---------|-------------|
| **Challenge cards** | Browse all 6 scenarios with difficulty badges and completion status |
| **Hints** | Expandable hint panels (no spoilers until you click) |
| **Credentials panel** | Starting identity details displayed per challenge |
| **Flag submission** | Submit flags directly in the GUI — instant validation |
| **Run scripts** | Setup and cleanup scripts execute in the same terminal session |
| **Solution viewer** | Read-only script viewer with copy/save/run buttons |
| **Progress tracking** | JSON state file persists completions across sessions |
| **Ram icons** | Random ram-mascot watermarks on each challenge page |

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Plus` or `Ctrl+NumPad+` | Zoom in (10% increments, max 200%) |
| `Ctrl+Minus` or `Ctrl+NumPad-` | Zoom out (10% increments, min 50%) |
| `Ctrl+0` or `Ctrl+NumPad0` | Reset zoom to 100% |

## Challenge Page

<!-- Screenshot: Challenge detail page with watermark -->
![Challenge Page](../screenshots/ps-gui-challenge.png)

Each challenge page shows:
- Difficulty and completion badges
- Full description
- Starting credentials (username, password, cert details)
- **Run Setup** / **Run Cleanup** buttons (execute in your terminal)
- **View Solution** button (read-only script viewer)
- Flag submission field
- Expandable hints

## Architecture

```
Start-EntraGoat.ps1          ← Entry point
EntraGoatGUI/
├── Data/Challenges.ps1      ← Challenge definitions (titles, flags, hints, creds)
├── Lib/
│   ├── Theme.ps1            ← Color palette, fonts, XAML token expansion
│   ├── State.ps1            ← JSON state read/write (%APPDATA%\EntraGoat\state.json)
│   ├── Scripts.ps1          ← Script path resolution + execution
│   └── UI.ps1               ← All WPF construction, navigation, event wiring
└── Views/
    ├── MainWindow.xaml       ← Window shell + nav bar
    ├── HomePage.xaml         ← Logo, stats, cards grid
    ├── ChallengePage.xaml    ← Challenge detail (watermark, hints, flag area)
    └── ScriptPage.xaml       ← Read-only script viewer
```

## Script Execution

When you click **Run Setup** or **Run Cleanup**, the GUI launches:

```powershell
Start-Process pwsh -ArgumentList "-File", "<script path>" -NoNewWindow
```

This runs the script **in the same terminal** that launched the GUI. Output appears in your console after the GUI closes or while it's still open.

## State Management

Completion state is stored as JSON:

```json
{ "completed": [1, 3, 5] }
```

Location: `%APPDATA%\EntraGoat\state.json`

Reset with:

```powershell
.\Start-EntraGoat.ps1 -Reset
```
