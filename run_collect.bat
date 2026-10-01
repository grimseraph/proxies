@echo off
cd /d %~dp0

echo ==============================================================
echo  Starting Aggregator Fast Refresh (Target: 20 low-delay nodes)
echo ==============================================================
echo.

call .venv\Scripts\activate.bat

python subscribe/collect.py -r -t clash mixed -m 20 -d 2000 %*

if exist data\mixed.txt (
    move /y data\mixed.txt data\v2ray.txt >nul
)

echo.
echo ==============================================================
echo  Finished! Files saved:
echo  - Clash: data\clash.yaml
echo  - v2ray: data\v2ray.txt (Base64)
echo ==============================================================
pause
