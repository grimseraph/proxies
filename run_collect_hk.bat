@echo off
cd /d %~dp0

echo ==============================================================
echo  Starting Aggregator Fast Refresh (HK Special: Min 5 HK nodes)
echo ==============================================================
echo.

call .venv\Scripts\activate.bat

python subscribe/collect.py -r -t clash singbox mixed -m 20 -d 2000 --min-hk 5 %*

copy /y data\clash.yaml data\clash_hk.yaml >nul 2>&1
copy /y data\singbox.json data\singbox_hk.json >nul 2>&1
copy /y data\mixed.txt data\mixed_hk.txt >nul 2>&1
powershell -Command "if (Test-Path 'data\mixed_hk.txt') { [Convert]::ToBase64String([IO.File]::ReadAllBytes('data\mixed_hk.txt')) | Out-File -Encoding ascii 'data\v2ray_hk.txt' }" >nul 2>&1

echo.
echo ==============================================================
echo  Finished! HK Dedicated files saved:
echo  - data\clash_hk.yaml
echo  - data\v2ray_hk.txt
echo  - data\singbox_hk.json
echo  - data\mixed_hk.txt
echo ==============================================================
pause
