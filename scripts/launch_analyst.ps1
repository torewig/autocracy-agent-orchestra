# launch_analyst.ps1
#
# Helper to copy the Analyst prompt for a given team to the clipboard,
# with [N] already substituted. Run this in a PowerShell terminal from
# the project root, then paste into a fresh Claude Code session.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File "scripts\launch_analyst.ps1" -team 01
#
# Or interactively: .\scripts\launch_analyst.ps1 -team 04

param(
    [Parameter(Mandatory=$true)]
    [string]$team
)

$projectdir = "C:\Users\torewig\Dropbox (Privat)\!!!!FORSKNING!!!!!\AUTOKNOW_ERC_COG\Papers\P02_autocracy-science-agent-orchestra"

# Pad to two digits if needed
if ($team.Length -eq 1) { $team = "0$team" }

$promptfile = "$projectdir\agents\prompt_analyst.md"
$teamdir    = "$projectdir\teams\team_$team"

# Check files exist
if (-not (Test-Path $promptfile)) {
    Write-Host "ERROR: agents/prompt_analyst.md not found." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path "$teamdir\preregistration.md")) {
    Write-Host "ERROR: teams/team_$team/preregistration.md not found. Run preregister.ps1 first." -ForegroundColor Red
    exit 1
}

# Ensure analysis/figures directory exists
New-Item -ItemType Directory -Path "$teamdir\analysis\figures" -Force | Out-Null

# Substitute [N] and copy to clipboard
$prompt = (Get-Content $promptfile -Raw -Encoding UTF8) -replace '\[N\]', $team
$prompt | Set-Clipboard

Write-Host ""
Write-Host "=== Team $team Analyst prompt ===" -ForegroundColor Cyan
Write-Host "Copied to clipboard. Open a fresh Claude Code session and paste." -ForegroundColor Green
Write-Host ""
Write-Host "  Team folder : teams/team_$team/"
Write-Host "  Preregistration: $(if (Test-Path "$teamdir\preregistration.md") { 'Found' } else { 'MISSING' })"
Write-Host "  Analysis dir   : teams/team_$team/analysis/ (created)"
Write-Host ""

# Warn about complex teams
$complexteams = @('05', '06', '10', '12', '23', '24', '25')
if ($complexteams -contains $team) {
    Write-Host "*** WARNING: Team $team is a COMPLEX team requiring an external API ***" -ForegroundColor Yellow
    switch ($team) {
        '05' { Write-Host "  API: Claude Haiku (Anthropic) | Est. cost: USD 800-900 | Hard ceiling: USD 1500" -ForegroundColor Yellow
               Write-Host "  Requires: ANTHROPIC_API_KEY environment variable" -ForegroundColor Yellow }
        '06' { Write-Host "  API: text-embedding-3-small (OpenAI) | Est. cost: ~USD 0.30" -ForegroundColor Yellow
               Write-Host "  Requires: OPENAI_API_KEY environment variable" -ForegroundColor Yellow }
        '10' { Write-Host "  API: Claude Haiku (Anthropic) | Est. cost: USD 5-10" -ForegroundColor Yellow
               Write-Host "  Requires: ANTHROPIC_API_KEY environment variable" -ForegroundColor Yellow }
        '12' { Write-Host "  API: Claude Haiku (Anthropic) | Est. cost: USD 5-10" -ForegroundColor Yellow
               Write-Host "  Requires: ANTHROPIC_API_KEY environment variable" -ForegroundColor Yellow }
        '23' { Write-Host "  API: Claude Haiku (Anthropic) | Est. cost: up to USD 500 | Hard ceiling: USD 500" -ForegroundColor Yellow
               Write-Host "  Requires: ANTHROPIC_API_KEY environment variable" -ForegroundColor Yellow }
        '24' { Write-Host "  API: Claude Haiku (Anthropic) | Est. cost: up to USD 500 | Hard ceiling: USD 500" -ForegroundColor Yellow
               Write-Host "  Requires: ANTHROPIC_API_KEY environment variable" -ForegroundColor Yellow }
        '25' { Write-Host "  API: Claude Haiku (Anthropic) | Est. cost: up to USD 500 | Hard ceiling: USD 500" -ForegroundColor Yellow
               Write-Host "  Requires: ANTHROPIC_API_KEY environment variable" -ForegroundColor Yellow }
    }
    Write-Host ""
}

Write-Host "Now open Claude Code and paste the prompt." -ForegroundColor Cyan
