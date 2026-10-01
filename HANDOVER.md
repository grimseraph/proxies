# Aggregator 本地极速版 - 部署与使用交接文档

## 📌 1. 项目概述

本项目基于开源代理聚合工具 [wzdnzd/aggregator](https://github.com/wzdnzd/aggregator) 构建，定位为**纯本地运行、按需极速获取优质低延迟节点的工具**。

经过针对性定制改造后，解决了原项目“运行耗时长（15~20分钟）、全量地毯式注册、输出格式单一、广告假节点多”等痛点，实现了**“15~30秒内自动测活并输出延迟最低的 20 个可用节点”**。

---

## 💻 2. 本地部署环境信息

* **部署路径**：`D:\ai\proxy`
* **操作系统**：Windows 11 (x86_64 / AMD64)
* **Python 环境**：Python 3.14.7 独立虚拟环境（位于 `D:\ai\proxy\.venv`）
* **依赖库**：`PyYAML`, `tqdm`, `geoip2`, `pycryptodomex`, `fofa-hack` 等已预装就绪
* **安全配置**：项目根目录已加入 Windows Defender 排除白名单（内置的 `clash` 与 `subconverter` 均可正常执行）
* **网络环境**：物理位置在新加坡，直连海外互联网，无需配置前置代理

---

## 🛠️ 3. 核心定制改动说明（相比原版的升级）

### ① 新增 `-m / --target-nodes` 早停机制（Early-Stopping）
* **代码修改**：[subscribe/collect.py](file:///d:/ai/proxy/subscribe/collect.py)
* **效果**：原版必须将数百个任务全部执行完毕才退出。改造后支持分批并发处理，**一旦通过 Clash 测活的合格节点达到设定目标（默认 20 个），立即停止后续所有耗时任务，提前收工**。耗时从 15 分钟降至 15~30 秒。

### ② 节点延迟自动测算与升序排列
* **代码修改**：[subscribe/clash.py](file:///d:/ai/proxy/subscribe/clash.py) 与 [subscribe/collect.py](file:///d:/ai/proxy/subscribe/collect.py)
* **效果**：测活时记录每个节点的真实往返延迟（RTT），最终生成配置时**严格按延迟从低到高排序**。排在最前列的即为当前网络下延迟最低、最顺畅的优质节点（在新加坡本地测出排在第一位的是新加坡本地 AnyTLS 节点）。

### ③ 现代多客户端多格式输出
* **代码与脚本优化**：[run_collect.bat](file:///d:/ai/proxy/run_collect.bat)、[run_collect.ps1](file:///d:/ai/proxy/run_collect.ps1)
* **效果**：
  * 原版 `v2ray` 目标仅支持陈旧的纯 VMess 协议。
  * 现已支持同步输出 **Clash**、**Sing-Box** 和 **Universal Mixed（通用明文多协议链接）**，全面覆盖 VLESS、Hysteria2、AnyTLS、Trojan、VMess 等现代协议。

### ④ Windows 兼容性脚本修复
* 提供标准 Windows 纯 ASCII CRLF 批处理脚本，彻底杜绝 CMD 下因 UTF-8 中文字节错乱导致的语法报错。

---

## 🚀 4. 日常使用方法

### 方式 1：双击运行（最简单，日常推荐）
直接在文件资源管理器中找到并**双击运行**：
`D:\ai\proxy\run_collect.bat`

### 方式 2：PowerShell 终端运行
```powershell
Set-Location D:\ai\proxy
.\.venv\Scripts\python subscribe\collect.py -r -t clash singbox mixed -m 20 -d 2000
```

### 常用运行参数说明
| 参数 | 说明 | 推荐值/默认值 |
| :--- | :--- | :--- |
| `-r` / `--refresh` | **极速刷新模式**：跳过网页注册，直接测活海量优质公共节点池 | **强烈建议日常带上**（15~30秒收工） |
| `-m` / `--target-nodes` | **目标节点数**：达到指定数量后立即早停并导出 | `20`（可按需改为 10 或 30） |
| `-d` / `--delay` | **延迟上限（毫秒）**：过滤掉高于该延迟的卡顿节点 | `2000`（如需更低延迟可设为 `1500`） |
| `-t` / `--targets` | **输出格式**：支持 clash、singbox、mixed | `clash singbox mixed` |
| `-c` / `--skip-captcha`| 爬虫模式下自动跳过带验证码的站点 | 爬取新机场时建议带上 |

---

## 📂 5. 产物输出与客户端使用指南

所有生成文件存放在 **`D:\ai\proxy\data\`**：

### 1. [data/clash.yaml](file:///d:/ai/proxy/data/clash.yaml)（Clash 完整配置）
* **适用客户端**：Clash Verge, Clash Nyanpasu, Clash Meta, Clash for Windows
* **使用方式**：直接把该 yaml 文件拖入客户端配置列表，或者新建本地 Profile 导入即可。包含完整的代理分组、自动测速选优策略组及分流规则。

### 2. [data/mixed.txt](file:///d:/ai/proxy/data/mixed.txt)（通用多协议节点列表）
* **适用客户端**：v2rayN, NekoBox, v2rayNG, Shadowrocket (小火箭), Quantumult X
* **使用方式**：打开文本全选复制，在客户端界面点击 **“从剪贴板导入”** 即可批量导入全部节点。支持 `vless://`, `hysteria2://`, `vmess://` 等通用协议。

### 3. [data/singbox.json](file:///d:/ai/proxy/data/singbox.json)（Sing-Box 完整配置）
* **适用客户端**：Sing-Box 各平台客户端
* **使用方式**：直接作为配置文件加载，20 个现代协议节点全部完整支持。

### 4. [data/subscribes.txt](file:///d:/ai/proxy/data/subscribes.txt)（订阅源列表）
* 维护用于 `-r` 极速测活的高质量公共订阅源列表。如果今后您有了自己的私人订阅，也可以按行追加在此文件中。

---

## ☁️ 6. GitHub Actions 远端云端运行指南

本项目配置了两个互补的独立 GitHub Actions 工作流：

| 工作流名称 | 配置文件 | 说明 |
| :--- | :--- | :--- |
| **Auto Collect and Refresh Proxies** | `.github/workflows/auto_refresh.yml` | **常规版**：按需提取 20 个全球低延迟节点 |
| **Auto Collect and Refresh Proxies 2 - HK Special** | `.github/workflows/auto_refresh_hk.yml` | **香港专线特供版**：测活并**确保包含至少 5 个低延迟香港优质节点** |

### 触发方式
* **纯按需手动触发**：打开 GitHub 仓库页面 $\to$ 点击 **Actions** 标签 $\to$ 选择想要的工作流 $\to$ 点击 **Run workflow** 按钮即可。

### 永久订阅直连地址（自动发布在 output 分支，两套独立共存）

#### 🇭🇰 香港专线特供版（保底 >= 5 个香港低延迟优质节点）：
* **Clash 香港专线**：
  `https://raw.githubusercontent.com/grimseraph/proxies/output/clash_hk.yaml`
* **v2ray 香港专线 (Base64)**：
  `https://raw.githubusercontent.com/grimseraph/proxies/output/v2ray_hk.txt`
* **Sing-Box 香港专线**：
  `https://raw.githubusercontent.com/grimseraph/proxies/output/singbox_hk.json`
* **明文香港专线列表**：
  `https://raw.githubusercontent.com/grimseraph/proxies/output/mixed_hk.txt`

#### 🌐 常规版（全球低延迟 20 节点混合）：
* **Clash 常规订阅**：
  `https://raw.githubusercontent.com/grimseraph/proxies/output/clash.yaml`
* **v2ray 常规订阅 (Base64)**：
  `https://raw.githubusercontent.com/grimseraph/proxies/output/v2ray.txt`
* **Sing-Box 常规订阅**：
  `https://raw.githubusercontent.com/grimseraph/proxies/output/singbox.json`
* **明文常规节点列表**：
  `https://raw.githubusercontent.com/grimseraph/proxies/output/mixed.txt`
