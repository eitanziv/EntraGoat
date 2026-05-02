#requires -Version 5.1
<#
.SYNOPSIS
  Launch the EntraGoat PowerShell GUI (WPF).
.DESCRIPTION
  An in-terminal alternative to the React/web UI. Lets you browse challenges,
  view starting credentials, see hints, submit flags, and view/run the
  setup/cleanup PowerShell scripts directly from a single window.
.PARAMETER Reset
  Clear all stored completion state before launching.
.EXAMPLE
  pwsh -File .\Start-EntraGoat.ps1
.EXAMPLE
  pwsh -File .\Start-EntraGoat.ps1 -Reset
#>
[CmdletBinding()]
param(
    [switch]$Reset
)

$ErrorActionPreference = 'Stop'

# Required for WPF.
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Xaml

$root = $PSScriptRoot
. (Join-Path $root 'EntraGoatGUI\Lib\Theme.ps1')
. (Join-Path $root 'EntraGoatGUI\Lib\State.ps1')
. (Join-Path $root 'EntraGoatGUI\Lib\Scripts.ps1')
. (Join-Path $root 'EntraGoatGUI\Lib\UI.ps1')
. (Join-Path $root 'EntraGoatGUI\Data\Challenges.ps1')

if ($Reset) {
    Reset-EntraGoatState
    Write-Host "EntraGoat completion state cleared." -ForegroundColor Yellow
}

$data = Get-EntraGoatChallenges
Show-EntraGoatMainWindow -Challenges $data.Challenges
