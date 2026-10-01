@echo off
cd /d %~dp0

echo ==============================================================
echo  Starting Aggregator Fast Refresh (HK Special: Min 5 HK nodes)
echo ==============================================================
echo.

call .venv\Scripts\activate.bat

python subscribe/collect.py -r -t clash singbox mixed -m 20 -d 2000 --min-hk 5 %*

echo.
echo ==============================================================
echo  Finished! 20 nodes (Min 5 HK nodes) saved in data/
echo ==============================================================
pause
