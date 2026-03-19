# admin_audit.ps1 — Run the administrative audit agent
#
# Usage (from project root):
#   powershell -ExecutionPolicy Bypass -File scripts\admin_audit.ps1
#
# This opens Claude Code with the admin agent prompt. The agent will:
#   1. Scan all directories against PLAN.md
#   2. Generate an updated STATUS.md
#   3. Flag loose ends and issues
#   4. Offer to commit changes to git

$projectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $projectRoot

$promptFile = Join-Path $projectRoot "agents\prompt_admin.md"

if (-not (Test-Path $promptFile)) {
    Write-Error "Admin prompt not found at: $promptFile"
    exit 1
}

$prompt = Get-Content $promptFile -Raw

Write-Host "=== Agent Orchestra: Administrative Audit ===" -ForegroundColor Cyan
Write-Host "Project root: $projectRoot"
Write-Host "Starting Claude Code with admin agent prompt..."
Write-Host ""

# Run Claude Code in non-interactive mode
claude --print $prompt
