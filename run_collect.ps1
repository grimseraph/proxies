Set-Location -Path $PSScriptRoot
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host " Starting Aggregator Fast Refresh (Target: 20 low-delay nodes)" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan

& "$PSScriptRoot\.venv\Scripts\python.exe" "$PSScriptRoot\subscribe\collect.py" -r -t clash mixed -m 20 -d 2000 $args

if (Test-Path "$PSScriptRoot\data\mixed.txt") {
    [Convert]::ToBase64String([IO.File]::ReadAllBytes("$PSScriptRoot\data\mixed.txt")) | Out-File -Encoding ascii "$PSScriptRoot\data\v2ray.txt"
    Remove-Item "$PSScriptRoot\data\mixed.txt" -Force
}

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Green
Write-Host " Finished! Files saved:" -ForegroundColor Green
Write-Host " - Clash: data\clash.yaml" -ForegroundColor Green
Write-Host " - v2ray: data\v2ray.txt (Base64)" -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Read-Host "Press Enter to exit..."
