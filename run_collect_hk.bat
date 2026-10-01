@echo off
cd /d %~dp0

echo ==============================================================
echo  Starting Aggregator Fast Refresh (HK Special: Min 5 HK nodes)
echo ==============================================================
echo.

call .venv\Scripts\activate.bat

python subscribe/collect.py -r -t clash mixed -m 20 -d 2000 --min-hk 5 %*

copy /y data\clash.yaml data\clash_hk.yaml >nul 2>&1
powershell -Command "if (Test-Path 'data\mixed.txt') { [Convert]::ToBase64String([IO.File]::ReadAllBytes('data\mixed.txt')) | Out-File -Encoding ascii 'data\v2ray_hk.txt'; Remove-Item 'data\mixed.txt' -Force }" >nul 2>&1

echo.
echo ==============================================================
echo  Finished! HK Dedicated files saved:
echo  - Clash: data\clash_hk.yaml
echo  - v2ray: data\v2ray_hk.txt (Base64)
echo ==============================================================
pause
