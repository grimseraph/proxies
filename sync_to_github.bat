@echo off
cd /d %~dp0

echo ==============================================================
echo  Syncing Local Subscription Files to GitHub (output branch)
echo ==============================================================
echo.

call .venv\Scripts\activate.bat
python scripts\sync_output.py

echo.
echo ==============================================================
pause
