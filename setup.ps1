<#
.SYNOPSIS
    Deploys KPM Technologies AI R&D Squad agent/skill/CLAUDE.md from repo to ~/.claude/.

.DESCRIPTION
    Reads source files from $PSScriptRoot/claude/ and copies them to $env:USERPROFILE/.claude/
    while substituting:
        {{SQUAD_HOME}}  -> $PSScriptRoot (repo location)
        {{CLAUDE_HOME}} -> $env:USERPROFILE\.claude

    Idempotent — safe to re-run after every git pull.

.PARAMETER ClaudeHome
    Override Claude config home. Default: $env:USERPROFILE\.claude

.PARAMETER Force
    Overwrite existing files without confirmation.

.EXAMPLE
    .\setup.ps1
    Deploy with defaults.

.EXAMPLE
    .\setup.ps1 -ClaudeHome "D:\custom\.claude"
    Deploy to a custom Claude home.
#>

param(
    [string]$ClaudeHome = "$env:USERPROFILE\.claude",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$SquadHome = $PSScriptRoot
$Source = Join-Path $SquadHome "claude"

if (-not (Test-Path $Source)) {
    Write-Error "Source directory not found: $Source"
    exit 1
}

Write-Host ""
Write-Host "=== KPM Technologies AI R&D Squad — Setup ===" -ForegroundColor Cyan
Write-Host "Repo (SQUAD_HOME):    $SquadHome"
Write-Host "Target (CLAUDE_HOME): $ClaudeHome"
Write-Host ""

# Ensure target dirs exist
foreach ($sub in @("agents", "skills", "commands", "rules")) {
    $dir = Join-Path $ClaudeHome $sub
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Substitute placeholders + write to destination (skip if unchanged to avoid lock conflicts)
function Deploy-File {
    param(
        [string]$SrcFile,
        [string]$DestFile
    )
    $content = [IO.File]::ReadAllText($SrcFile)
    $content = $content -replace '\{\{SQUAD_HOME\}\}', $SquadHome
    $content = $content -replace '\{\{CLAUDE_HOME\}\}', $ClaudeHome

    $destDir = Split-Path $DestFile -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    # Skip write if content already matches — avoids lock conflicts when Claude Code
    # has the deployed file open
    if (Test-Path $DestFile) {
        $existing = [IO.File]::ReadAllText($DestFile)
        if ($existing -eq $content) {
            return
        }
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($DestFile, $content, $utf8NoBom)
}

# Deploy CLAUDE.md
Deploy-File -SrcFile (Join-Path $Source "CLAUDE.md") -DestFile (Join-Path $ClaudeHome "CLAUDE.md")
Write-Host "[OK] CLAUDE.md" -ForegroundColor Green

# Deploy agents
$agentCount = 0
Get-ChildItem (Join-Path $Source "agents") -Filter "*.md" | ForEach-Object {
    Deploy-File -SrcFile $_.FullName -DestFile (Join-Path $ClaudeHome "agents\$($_.Name)")
    $agentCount++
}
Write-Host "[OK] Agents: $agentCount" -ForegroundColor Green

# Deploy skills (recursive, preserving structure)
$skillCount = 0
Get-ChildItem (Join-Path $Source "skills") -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring((Join-Path $Source "skills").Length + 1)
    Deploy-File -SrcFile $_.FullName -DestFile (Join-Path $ClaudeHome "skills\$rel")
    $skillCount++
}
Write-Host "[OK] Skill files: $skillCount" -ForegroundColor Green

# Deploy commands (slash commands)
$commandCount = 0
$commandsSource = Join-Path $Source "commands"
if (Test-Path $commandsSource) {
    Get-ChildItem $commandsSource -Filter "*.md" | ForEach-Object {
        Deploy-File -SrcFile $_.FullName -DestFile (Join-Path $ClaudeHome "commands\$($_.Name)")
        $commandCount++
    }
}
Write-Host "[OK] Commands: $commandCount" -ForegroundColor Green

# Deploy rules (always-active rules)
$ruleCount = 0
$rulesSource = Join-Path $Source "rules"
if (Test-Path $rulesSource) {
    Get-ChildItem $rulesSource -Filter "*.md" | ForEach-Object {
        Deploy-File -SrcFile $_.FullName -DestFile (Join-Path $ClaudeHome "rules\$($_.Name)")
        $ruleCount++
    }
}
Write-Host "[OK] Rules: $ruleCount" -ForegroundColor Green

# Set SQUAD_HOME env var (user-scope) so tools/scripts can find the repo
$existingSquadHome = [Environment]::GetEnvironmentVariable("SQUAD_HOME", "User")
if ($existingSquadHome -ne $SquadHome) {
    [Environment]::SetEnvironmentVariable("SQUAD_HOME", $SquadHome, "User")
    Write-Host "[OK] Env var SQUAD_HOME set to: $SquadHome" -ForegroundColor Green
} else {
    Write-Host "[OK] Env var SQUAD_HOME already correct" -ForegroundColor Green
}

Write-Host ""
Write-Host "Setup complete. Restart Claude Code if it's running." -ForegroundColor Cyan
Write-Host ""
