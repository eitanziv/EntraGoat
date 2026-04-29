# State persistence for the EntraGoat PowerShell GUI.
# Stores completion state at %APPDATA%\EntraGoat\state.json.
# Schema: { "completed": [1, 3, ...] }

function Get-EntraGoatStatePath {
    $dir = Join-Path $env:APPDATA 'EntraGoat'
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Join-Path $dir 'state.json'
}

function Get-EntraGoatState {
    $path = Get-EntraGoatStatePath
    if (-not (Test-Path -LiteralPath $path)) {
        return [pscustomobject]@{ Completed = @() }
    }
    try {
        $raw = Get-Content -LiteralPath $path -Raw -ErrorAction Stop
        $obj = $raw | ConvertFrom-Json -ErrorAction Stop
        $completed = @()
        if ($obj.PSObject.Properties.Name -contains 'completed') {
            $completed = @($obj.completed | ForEach-Object { [int]$_ })
        }
        return [pscustomobject]@{ Completed = $completed }
    } catch {
        Write-Warning "Could not read EntraGoat state file ($path): $_. Starting fresh."
        return [pscustomobject]@{ Completed = @() }
    }
}

function Save-EntraGoatState {
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$State
    )
    $path = Get-EntraGoatStatePath
    $payload = [ordered]@{ completed = @($State.Completed | Sort-Object -Unique) }
    ($payload | ConvertTo-Json -Depth 4) | Set-Content -LiteralPath $path -Encoding UTF8
}

function Set-EntraGoatChallengeCompleted {
    param(
        [Parameter(Mandatory)]
        [int]$Id
    )
    $state = Get-EntraGoatState
    if ($state.Completed -notcontains $Id) {
        $state.Completed = @($state.Completed) + $Id
        Save-EntraGoatState -State $state
    }
    return $state
}

function Reset-EntraGoatState {
    $path = Get-EntraGoatStatePath
    if (Test-Path -LiteralPath $path) {
        Remove-Item -LiteralPath $path -Force
    }
}
