<#
.SYNOPSIS
    Pulls latest from GitHub and re-deploys to ~/.claude/.

.DESCRIPTION
    Convenience wrapper:
      1. git pull (in repo dir)
      2. .\setup.ps1

.PARAMETER NoPull
    Skip git pull (just re-deploy from current source).

.EXAMPLE
    .\sync.ps1
.EXAMPLE
    .\sync.ps1 -NoPull
#>

param(
    [switch]$NoPull
)

$ErrorActionPreference = "Stop"
$SquadHome = $PSScriptRoot

if (-not $NoPull) {
    Write-Host "git pull..." -ForegroundColor Cyan
    Push-Location $SquadHome
    try {
        git pull
        if ($LASTEXITCODE -ne 0) {
            Write-Error "git pull failed. Resolve and re-run."
            exit 1
        }
    } finally {
        Pop-Location
    }
}

& (Join-Path $SquadHome "setup.ps1")
