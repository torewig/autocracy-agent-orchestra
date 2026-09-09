# preregister.ps1
#
# Creates a timestamped preregistration.md for each approved team and commits
# to GitHub. Run this AFTER PI approval of all rq.md files (Step B) and
# BEFORE any Analyst session starts (Step C).
#
# A team is considered approved if it has both rq.md and analysis_plan.md.
# Usage:
#   powershell -ExecutionPolicy Bypass -File "scripts\preregister.ps1"

$projectdir = "C:\Users\torewig\Dropbox (Privat)\!!!!FORSKNING!!!!!\AUTOKNOW_ERC_COG\Papers\P02_autocracy-science-agent-orchestra"
Set-Location $projectdir

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Find approved teams (both rq.md and analysis_plan.md present)
$teams = Get-ChildItem -Path "teams" -Directory | Where-Object {
    (Test-Path "$($_.FullName)\rq.md") -and
    (Test-Path "$($_.FullName)\analysis_plan.md")
}

if ($teams.Count -eq 0) {
    Write-Host "No approved teams found (need both rq.md and analysis_plan.md)."
    exit 1
}

Write-Host "Found $($teams.Count) approved team(s). Creating preregistration files..."
Write-Host ""

$created = @()

foreach ($team in $teams) {
    $teamname     = $team.Name
    $rq_content   = Get-Content "$($team.FullName)\rq.md" -Raw -Encoding UTF8
    $plan_content = Get-Content "$($team.FullName)\analysis_plan.md" -Raw -Encoding UTF8
    $prereg_path  = "$($team.FullName)\preregistration.md"

    # Skip if preregistration already exists (avoid overwriting a prior commit)
    if (Test-Path $prereg_path) {
        Write-Host "  SKIP $teamname -- preregistration.md already exists"
        continue
    }

    $header = "# Pre-registration: $teamname`n`n**Timestamp:** $timestamp`n**Project:** AutoKnow ERC -- Autocracy and science`n**PI:** Tore Wig, University of Oslo`n`n> This document was committed to version control before any analysis was run.`n> The Git commit hash and timestamp serve as the pre-registration record.`n> The contents of this file must not be modified after the initial commit.`n`n---`n`n## Research Question`n`n"
    $separator = "`n`n---`n`n## Analysis Plan`n`n"

    $content = $header + $rq_content + $separator + $plan_content
    [System.IO.File]::WriteAllText($prereg_path, $content, [System.Text.Encoding]::UTF8)

    Write-Host "  Written: $teamname\preregistration.md"
    $created += "teams/$teamname/preregistration.md"
}

if ($created.Count -eq 0) {
    Write-Host ""
    Write-Host "No new preregistration files to commit (all teams already registered)."
    exit 0
}

Write-Host ""
Write-Host "Staging files for git commit..."

foreach ($f in $created) {
    git add -f $f
}

$msg = "Pre-registration: $($created.Count) team(s) - $timestamp"
git commit -m $msg

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: git commit failed."
    exit 1
}

Write-Host ""
Write-Host "Pushing to remote..."
git push

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: git push failed. Commit was created locally."
    Write-Host "Push manually with: git push"
    exit 1
}

Write-Host ""
Write-Host "=== Pre-registration complete ==="
Write-Host "Commit message: $msg"
Write-Host "Verify the commit on GitHub before starting any Analyst sessions."
Write-Host "The commit hash is the timestamped proof of pre-registration."
