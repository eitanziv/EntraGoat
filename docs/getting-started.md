# Getting Started

## Prerequisites

| Requirement | Details |
|-------------|---------|
| **Entra ID Tenant** | A test/trial tenant — **never use production** |
| **Permissions** | Global Administrator on the test tenant |
| **Graph SDK** | Microsoft Graph PowerShell SDK (`Microsoft.Graph` module) |
| **OS** | Windows (required for the PowerShell GUI — WPF) |
| **PowerShell** | Windows PowerShell 5.1 or PowerShell 7+ |
| **Node.js** *(optional)* | Only needed if using the web UI |

## Installation

```bash
git clone https://github.com/Semperis/EntraGoat
cd EntraGoat
```

### Install the Graph SDK

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force
```

If you already have it, ensure it's up to date:

```powershell
Update-Module Microsoft.Graph
```

## Running EntraGoat

### PowerShell GUI (recommended)

```powershell
.\Start-EntraGoat.ps1
```

A dark-themed WPF window will open with all six challenges, hints, credentials, and buttons to run setup/cleanup scripts directly.

**Flags:**

| Flag | Effect |
|------|--------|
| `-Reset` | Clears stored completion state before launching |

**Keyboard shortcuts:**

| Shortcut | Action |
|----------|--------|
| `Ctrl+Plus` | Zoom in |
| `Ctrl+Minus` | Zoom out |
| `Ctrl+0` | Reset zoom to 100% |

### Web UI

```bash
cd frontend
npm install
npm start
```

Open `http://localhost:3000`. Click a challenge card to view details, then run the corresponding setup script from your terminal.

### Manual (no GUI)

```powershell
cd scenarios
.\EntraGoat-Scenario1-Setup.ps1
```

## How it works

1. **Setup** — Each scenario script creates users, apps, groups, and/or role assignments in your tenant with intentional misconfigurations.
2. **Play** — You're given a low-privilege starting identity. Enumerate, discover the attack path, and escalate to Global Admin.
3. **Flag** — The flag is a unique string stored in `extensionAttribute1` on the admin user (or similar location noted in the challenge).
4. **Cleanup** — The cleanup script removes all objects created by the scenario.

## Completion state

Progress is stored at:

```
%APPDATA%\EntraGoat\state.json
```

The PowerShell GUI and web UI track state independently. Use `.\Start-EntraGoat.ps1 -Reset` to clear PS GUI progress.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Install-Module` fails | Run PowerShell as Administrator, or add `-Scope CurrentUser` |
| Graph authentication error | Run `Connect-MgGraph -Scopes "Directory.ReadWrite.All"` manually first |
| WPF errors on macOS/Linux | The PowerShell GUI requires Windows. Use the web UI or manual scripts instead |
| Setup script fails mid-way | Run the cleanup script first, then retry setup |
