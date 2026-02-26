$pandoc  = "C:\Program Files\RStudio\resources\app\bin\quarto\bin\tools\pandoc.exe"
$xelatex = "C:\Program Files\MiKTeX\miktex\bin\x64\xelatex.exe"
$infile  = "C:\Users\torewig\Dropbox (Privat)\!!!!FORSKNING!!!!!\AUTOKNOW_ERC_COG\Papers\Autocracy and science_Agent Orchestra\PLAN.md"
$outfile = "C:\Users\torewig\Dropbox (Privat)\!!!!FORSKNING!!!!!\AUTOKNOW_ERC_COG\Papers\Autocracy and science_Agent Orchestra\PLAN.pdf"

& $pandoc $infile `
    --pdf-engine=$xelatex `
    --from=markdown-task_lists `
    -V geometry:margin=2.5cm `
    -V fontsize=11pt `
    -V colorlinks=true `
    -V mainfont="Georgia" `
    -V monofont="Consolas" `
    -V monofontoptions="Scale=0.85" `
    -o $outfile

if ($LASTEXITCODE -eq 0) {
    Write-Host "PDF written: $outfile"
} else {
    Write-Host "pandoc failed with exit code $LASTEXITCODE"
}
