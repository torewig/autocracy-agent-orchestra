$r = "C:\Program Files\R\R-4.5.1\bin\Rscript.exe"

# Step 1: Update vdem_clean.rds with extended variables
Write-Host "=== Updating vdem_clean.rds ==="
& $r "C:\Users\torewig\Dropbox (Privat)\!!!!FORSKNING!!!!!\AUTOKNOW_ERC_COG\DATA\vdem\install_github.R"

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: V-DEM update failed. Aborting."
    exit 1
}

# Step 2: Run Phase 0 data preparation
Write-Host ""
Write-Host "=== Running 00_prepare_data.R ==="
Set-Location "C:\Users\torewig\Dropbox (Privat)\!!!!FORSKNING!!!!!\AUTOKNOW_ERC_COG\Papers\Autocracy and science_Agent Orchestra"
& $r "scripts/00_prepare_data.R"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Phase 0 complete."
} else {
    Write-Host "ERROR: 00_prepare_data.R failed with exit code $LASTEXITCODE"
}
