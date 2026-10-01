@echo off
cd /d %~dp0

echo ==============================================================
echo  Starting Aggregator Fast Refresh (Target: 20 low-delay nodes)
echo ==============================================================
echo.

call .venv\Scripts\activate.bat

python subscribe/collect.py -r -t clash singbox mixed -m 20 -d 2000 %*

echo.
echo ==============================================================
echo  Finished!
echo  - Clash:    data/clash.yaml
echo  - SingBox:  data/singbox.json
echo  - Universal:data/mixed.txt (vless/hysteria2/vmess links)
echo ==============================================================
pause
