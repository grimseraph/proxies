@echo off
cd /d %~dp0

echo ==============================================================
echo  Starting Aggregator Fast Refresh (HK Special: Min 5 HK nodes)
echo ==============================================================
echo.

call .venv\Scripts\activate.bat

python subscribe/collect.py -r -t clash mixed -m 20 -d 2000 --min-hk 5 %*

copy /y data\clash.yaml data\clash_hk.yaml >nul 2>&1
if exist data\mixed.txt (
    move /y data\mixed.txt data\v2ray_hk.txt >nul
)

echo.
echo ==============================================================
echo  Finished! HK Dedicated files saved:
echo  - Clash: data\clash_hk.yaml
echo  - v2ray: data\v2ray_hk.txt (Base64)
echo ==============================================================
echo.
set /p sync="Do you want to sync these nodes to GitHub subscription? (Y/N, default: N): "
if /i "%sync%"=="y" (
    echo.
    python scripts\sync_output.py
)

echo.
pause
