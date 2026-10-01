# 项目调优与变更日志 (CHANGELOG)

## [2026-10-01] 本地化部署与极速早停功能升级

### 1. 部署与初始化
* **代码拉取**：成功将 `https://github.com/wzdnzd/aggregator.git` 克隆至本地 `D:\ai\proxy`。
* **独立环境**：创建专属 Python 虚拟环境 `.venv`，并安装全部基础依赖（`PyYAML`, `tqdm`, `geoip2`, `pycryptodomex`, `fofa-hack`）。
* **二进制检验**：验证 Windows AMD64 下内置的 `clash-windows-amd.exe` 和 `subconverter-windows-amd.exe` 可执行权限及运行状态。

---

### 2. 核心功能定制开发

#### A. 早停机制 (Early Stopping)
* **涉及文件**：`subscribe/collect.py`
* **变更内容**：
  * 在命令行参数中新增 `-m / --target-nodes`（指定收集可用节点的目标数量，默认 0 表示全量）；
  * 新增 `--max-sites`（限制最大尝试注册站点数）；
  * 改造 `aggregate()` 函数的执行流程：将原先一次性并发执行全部 300+ 机场任务，改为以 10 个为一批分批提交并结合 Clash 实时测活；
  * 一旦累积测活通过的合格节点达到 `target_nodes`，立即触发 `break` 中断后续批次，提前保存并退出。
* **解决痛点**：避免了原版长达 15~20 分钟的地毯式无效等待，将整体按需收集耗时压缩至 15~30 秒。

#### B. 真实延迟记录与排序 (Latency Sorting)
* **涉及文件**：`subscribe/clash.py`, `subscribe/collect.py`
* **变更内容**：
  * 修改 `clash.check()` 函数，在检测节点可用性的同时，提取并存储实测往返延迟数值 `proxy["delay"]`；
  * 在最后生成节点列表前，使用 `tested_nodes.sort(key=lambda x: x.get("delay", 999999))` 按照延迟从小到大升序排序，并在导出时清除临时标记；
  * 优先将延迟最低的本地/邻近节点排在最前列。

#### C. 多客户端格式适配 (Target Format Tuning)
* **涉及文件**：`subscribe/subconverter.py`, `run_collect.bat`, `run_collect.ps1`
* **问题排查**：
  * 用户发现 `v2ray.txt` 只有单行内容。经深入排查发现：Subconverter 中的 `target=v2ray` 属于陈旧规范，仅支持纯 VMess 协议；而新抓取的高质量节点大量使用 VLESS、Hysteria2、AnyTLS，被纯 v2ray 目标全部过滤淘汰。
* **解决方案**：
  * 将导出目标升级为 `clash singbox mixed`：
    * `clash.yaml`：全量支持 20 个现代节点；
    * `singbox.json`：全量支持 20 个现代节点；
    * `mixed.txt`：输出通用明文 URI 列表（以 `vless://`, `hysteria2://`, `vmess://` 开头），完美适配 v2rayN、NekoBox、Shadowrocket 等通用工具。

#### D. Windows 批处理编码与兼容性修复
* **涉及文件**：`run_collect.bat`, `run_collect.ps1`
* **问题排查**：
  * Windows CMD 默认代码页为 GBK/CP936，在解析含 UTF-8 中文和 LF 换行符的 bat 文件时，因字节错乱将汉字误拆解成非法指令报错。
* **解决方案**：
  * 使用纯 ASCII 字符结合标准 Windows CRLF 换行符重写 `run_collect.bat`，保证任意系统环境下双击稳定运行；
  * 同步提供原生 PowerShell 版本的 `run_collect.ps1`。

---

### 3. 数据与节点池调优
* **涉及文件**：`data/subscribes.txt`
* **问题排查**：
  * Telegram 抓取的临时机场充斥大量“流量剩余/套餐说明/官网广告”假节点，真实有效节点率极低。
* **解决方案**：
  * 在 `data/subscribes.txt` 中引入多条由开源社区每日自动化维护的高质量节点聚合源；
  * 在日常使用中搭配 `-r`（`--refresh`）参数，直接对高质量节点池执行快速测活，秒级产出 20 个极速节点。
