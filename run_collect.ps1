Set-Location -Path $PSScriptRoot
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host " Starting Aggregator Fast Refresh (Target: 20 low-delay nodes)" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan

& "$PSScriptRoot\.venv\Scripts\python.exe" "$PSScriptRoot\subscribe\collect.py" -r -t clash singbox mixed -m 20 -d 2000 $args

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Green
Write-Host " Finished!" -ForegroundColor Green
Write-Host " - Clash:     data/clash.yaml" -ForegroundColor Green
Write-Host " - SingBox:   data/singbox.json" -ForegroundColor Green
Write-Host " - Universal: data/mixed.txt (vless/hysteria2/vmess links)" -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Read-Host "Press Enter to exit..."
