# run_team06.ps1 — Team 06 unattended embedding job
# Run from any PowerShell window. Logs all output to teams/team_06/analysis/run_log.txt
# Resume-safe: picks up from cache automatically if interrupted.
# After job completes, run:  [Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $null, "User")

$proj    = "C:\Users\torewig\Dropbox (Privat)\!!!!FORSKNING!!!!!\AUTOKNOW_ERC_COG\Papers\Autocracy and science_Agent Orchestra"
$rscript = "C:\Program Files\R\R-4.5.1\bin\Rscript.exe"
$script  = "$proj\teams\team_06\analysis\analysis.R"
$logFile = "$proj\teams\team_06\analysis\run_log.txt"

# Check API key is available
if ([string]::IsNullOrEmpty($env:OPENAI_API_KEY)) {
    Write-Error "OPENAI_API_KEY not set. Open a NEW PowerShell window and try again."
    exit 1
}

$start = Get-Date
"" | Out-File -FilePath $logFile -Append
"================================================================" | Out-File -FilePath $logFile -Append
"  Team 06 job started: $start" | Out-File -FilePath $logFile -Append
"================================================================" | Out-File -FilePath $logFile -Append

Write-Host "Team 06 job started: $start"
Write-Host "Logging to: $logFile"
Write-Host "Press Ctrl+C to interrupt (progress is saved to cache every 20 batches)."
Write-Host ""

# Run — stream output to both console and log
& $rscript $script 2>&1 | Tee-Object -FilePath $logFile -Append

$elapsed = (Get-Date) - $start
"" | Out-File -FilePath $logFile -Append
"================================================================" | Out-File -FilePath $logFile -Append
"  Job finished: $(Get-Date)  |  Elapsed: $([math]::Round($elapsed.TotalHours, 2)) hours" | Out-File -FilePath $logFile -Append
"================================================================" | Out-File -FilePath $logFile -Append

Write-Host ""
Write-Host "Done. Elapsed: $([math]::Round($elapsed.TotalHours, 2)) hours"
Write-Host "Results: $proj\teams\team_06\analysis\primary_results.json"
Write-Host ""
Write-Host "To remove the API key from the registry, run:"
Write-Host '  [Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $null, "User")'
