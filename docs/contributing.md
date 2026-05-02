# Contributing to EntraGoat

We welcome contributions from the security community! Here's how you can help.

## Ways to contribute

| Type | Description |
|------|-------------|
| **New scenarios** | Additional privilege escalation paths and attack vectors |
| **Code improvements** | PowerShell script optimization, error handling, compatibility |
| **Documentation** | Walkthroughs, tips, translations |
| **Bug reports** | Setup failures, edge cases, compatibility issues |
| **Feature requests** | GUI improvements, new functionality |

## Adding a new scenario

1. Create `scenarios/EntraGoat-ScenarioN-Setup.ps1` — deploys the vulnerable configuration
2. Create `cleanups/EntraGoat-ScenarioN-Cleanup.ps1` — removes all created objects
3. Create `solutions/EntraGoat-ScenarioN-Solution.ps1` — step-by-step attack walkthrough
4. Add the challenge definition to `EntraGoatGUI/Data/Challenges.ps1`
5. Add corresponding scripts to `frontend/public/scripts/challengeN/`

### Scenario conventions

- Use a unique, descriptive admin UPN: `EntraGoat-admin-sN@<tenant>`
- Store the flag in `extensionAttribute1` on the admin user
- End setup scripts with a success message + `"====="` separator
- End cleanup scripts with `"Cleanup process for Scenario N complete."` + `"====="` separator
- Include at least 2-3 hints of escalating specificity

## Development setup

```powershell
git clone https://github.com/Semperis/EntraGoat
cd EntraGoat
git checkout -b feature/my-change
```

Test the PowerShell GUI:

```powershell
.\Start-EntraGoat.ps1
```

Test the web UI:

```bash
cd frontend && npm install && npm start
```

## Pull request guidelines

- One feature/fix per PR
- Test both GUIs if your change affects shared data (challenges, scripts)
- Include a brief description of what the scenario teaches (for new scenarios)
- Ensure cleanup scripts fully remove all created objects

## Code style

- Match existing conventions (no reformatting unrelated code)
- PowerShell: follow the existing `Write-Host` coloring patterns for output
- Use `Write-Host` for player-facing output, `Write-Verbose` for debug details
