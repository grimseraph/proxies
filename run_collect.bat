@echo off
cd /d %~dp0

echo ==============================================================
echo  Starting Aggregator Fast Refresh (Target: 20 low-delay nodes)
echo ==============================================================
echo.

call .venv\Scripts\activate.bat

python subscribe/collect.py -r -t clash mixed -m 20 -d 2000 %*

powershell -Command "if (Test-Path 'data\mixed.txt') { [Convert]::ToBase64String([IO.File]::ReadAllBytes('data\mixed.txt')) | Out-File -Encoding ascii 'data\v2ray.txt'; Remove-Item 'data\mixed.txt' -Force }" >nul 2>&1

echo.
echo ==============================================================
echo  Finished! Files saved:
echo  - Clash: data\clash.yaml
echo  - v2ray: data\v2ray.txt (Base64)
echo ==============================================================
pause
