$dir = "C:\Users\torewig\Dropbox (Privat)\!!!!FORSKNING!!!!!\AUTOKNOW_ERC_COG\DATA\bibliometric\WOS_scrapes"
Write-Host "WOS_scrapes folder - all files:"
Get-ChildItem $dir -File |
    Select-Object Name, @{n='GB';e={[math]::Round($_.Length/1GB,3)}}, LastWriteTime |
    Sort-Object LastWriteTime -Descending |
    Format-Table -AutoSize
