# Resolves and (optionally) executes EntraGoat scenario / cleanup / solution scripts.

function Resolve-EntraGoatScript {
    param(
        [Parameter(Mandatory)][int]$Id,
        [Parameter(Mandatory)][ValidateSet('Setup','Cleanup','Solution')][string]$Type
    )
    $root = Split-Path -Parent (Get-EntraGoatRootPath)  # repo root (parent of EntraGoatGUI)
    switch ($Type) {
        'Setup'    { $folder = 'scenarios'; $name = "EntraGoat-Scenario$Id-Setup.ps1" }
        'Cleanup'  { $folder = 'cleanups';  $name = "EntraGoat-Scenario$Id-Cleanup.ps1" }
        'Solution' { $folder = 'solutions'; $name = "EntraGoat-Scenario$Id-Solution.ps1" }
    }
    $path = Join-Path (Join-Path $root $folder) $name
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Script not found: $path"
    }
    return $path
}

function Invoke-EntraGoatScript {
    # Executes a scenario script in the current PowerShell session.
    # WARNING: setup/cleanup scripts modify your Entra tenant. The caller is
    # responsible for showing a confirmation dialog before invoking this.
    param(
        [Parameter(Mandatory)][string]$Path
    )
    & $Path
}
