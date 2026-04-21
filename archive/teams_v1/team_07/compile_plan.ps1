$pandoc  = "C:\Program Files\RStudio\resources\app\bin\quarto\bin\tools\pandoc.exe"
$xelatex = "C:\Program Files\MiKTeX\miktex\bin\x64\xelatex.exe"
$base    = "C:\Users\torewig\Dropbox (Privat)\!!!!FORSKNING!!!!!\AUTOKNOW_ERC_COG\Papers\Autocracy and science_Agent Orchestra\teams\team_07"

# Combine rq.md and analysis_plan.md with a page break between them
$combined = "$base\plan_combined.md"
$rq       = Get-Content "$base\rq.md" -Raw
$ap       = Get-Content "$base\analysis_plan.md" -Raw
$header   = @"
---
title: "Team 07 — Research Design"
subtitle: "AutoKnow Agent Orchestra"
date: "2026-03-19"
geometry: margin=2.5cm
fontsize: 11pt
mainfont: "Calibri"
---

"@
Set-Content -Path $combined -Value ($header + $rq + "`n`n---`n`n" + $ap)

# Convert to PDF via xelatex
& $pandoc $combined `
  --pdf-engine=$xelatex `
  --output="$base\plan.pdf"

Write-Output "Done: $base\plan.pdf"
