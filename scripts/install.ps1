param (
    [string]$TargetDir = "."
)

$ErrorActionPreference = "Stop"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " OpenSpec-Guard: Project Injection Utility  " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$ResolvedTarget = Resolve-Path $TargetDir
Write-Host "Target Project: $ResolvedTarget" -ForegroundColor Yellow

$SourceRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

# 1. Copy .agents workflows and skills
$targetAgents = Join-Path $ResolvedTarget ".agents"
$targetWorkflows = Join-Path $targetAgents "workflows"
$targetSkills = Join-Path $targetAgents "skills"

New-Item -ItemType Directory -Path $targetWorkflows -Force | Out-Null
New-Item -ItemType Directory -Path $targetSkills -Force | Out-Null

Copy-Item -Path "$SourceRoot\.agents\workflows\*" -Destination $targetWorkflows -Recurse -Force
Copy-Item -Path "$SourceRoot\.agents\skills\*" -Destination $targetSkills -Recurse -Force

Write-Host "[OK] Workflows and Skills injected into .agents/" -ForegroundColor Green

# 2. Copy openspec baseline structure
$targetOpenSpec = Join-Path $ResolvedTarget "openspec"
$targetChanges = Join-Path $targetOpenSpec "changes\archive"
$targetSpecs = Join-Path $targetOpenSpec "specs"

New-Item -ItemType Directory -Path $targetChanges -Force | Out-Null
New-Item -ItemType Directory -Path $targetSpecs -Force | Out-Null

if (-not (Test-Path "$targetOpenSpec\config.yaml")) {
    Copy-Item -Path "$SourceRoot\openspec\config.yaml" -Destination "$targetOpenSpec\config.yaml" -Force
    Write-Host "[OK] Created baseline openspec/config.yaml" -ForegroundColor Green
} else {
    Write-Host "[INFO] openspec/config.yaml already exists. Preserved existing config." -ForegroundColor Cyan
}

New-Item -ItemType File -Path "$targetChanges\.gitkeep" -Force | Out-Null
New-Item -ItemType File -Path "$targetSpecs\.gitkeep" -Force | Out-Null

Write-Host "=============================================" -ForegroundColor Green
Write-Host " OpenSpec-Guard successfully installed!    " -ForegroundColor Green
Write-Host " Available Slash Commands:                  " -ForegroundColor Green
Write-Host "   /opsx-propose  - Propose change & specs  " -ForegroundColor White
Write-Host "   /opsx-apply    - Code & auto tri-audit   " -ForegroundColor White
Write-Host "   /opsx-audit    - Standalone read-only audit" -ForegroundColor White
Write-Host "   /opsx-archive  - Gated merge & archive   " -ForegroundColor White
Write-Host "=============================================" -ForegroundColor Green
