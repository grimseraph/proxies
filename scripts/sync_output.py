# -*- coding: utf-8 -*-
import os
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timezone

def sync():
    root = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))
    data_dir = os.path.join(root, "data")

    # Files to look for in data/
    target_files = ["clash.yaml", "v2ray.txt", "clash_hk.yaml", "v2ray_hk.txt"]
    available = [f for f in target_files if os.path.exists(os.path.join(data_dir, f))]

    if not available:
        print("[!] No subscription files found in data/ directory.")
        print("    Please run run_collect.bat or run_collect_hk.bat first.")
        return

    print(f"[*] Found {len(available)} files to sync: {', '.join(available)}")

    temp_dir = tempfile.mkdtemp(prefix="proxy_sync_")
    try:
        # Clone output branch
        print("[*] Fetching output branch from GitHub...")
        clone_cmd = [
            "git", "clone", "--depth", "1", "--branch", "output",
            "https://github.com/grimseraph/proxies.git", temp_dir
        ]
        ret = subprocess.run(clone_cmd, capture_output=True, text=True)
        if ret.returncode != 0:
            print("[!] Failed to clone output branch:", ret.stderr.strip())
            return

        # Copy available files
        for f in available:
            src = os.path.join(data_dir, f)
            dst = os.path.join(temp_dir, f)
            shutil.copy2(src, dst)
            print(f"  + Updated {f}")

        # Update README
        utc_now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
        readme_path = os.path.join(temp_dir, "README.md")
        with open(readme_path, "w", encoding="utf-8") as rf:
            rf.write("# 节点订阅链接 / Subscription Links\n\n")
            rf.write("本分支由本地测速 / GitHub Actions 自动维护，包含常规版与香港专线特供版两套独立订阅。\n\n")
            rf.write("### 🇭🇰 香港专线特供版（保底 >= 5 个香港低延迟优质节点）：\n")
            rf.write("- **Clash 香港专线**: https://raw.githubusercontent.com/grimseraph/proxies/output/clash_hk.yaml\n")
            rf.write("- **v2ray 香港专线 (Base64)**: https://raw.githubusercontent.com/grimseraph/proxies/output/v2ray_hk.txt\n\n")
            rf.write("### 🌐 常规版（全球低延迟 20 节点混合）：\n")
            rf.write("- **Clash 常规订阅**: https://raw.githubusercontent.com/grimseraph/proxies/output/clash.yaml\n")
            rf.write("- **v2ray 常规订阅 (Base64)**: https://raw.githubusercontent.com/grimseraph/proxies/output/v2ray.txt\n\n")
            rf.write(f"最后更新时间 (UTC): {utc_now}\n")

        # Commit and push
        subprocess.run(["git", "add", "."], cwd=temp_dir, check=True)
        diff_ret = subprocess.run(["git", "diff", "--staged", "--quiet"], cwd=temp_dir)
        if diff_ret.returncode == 0:
            print("[*] No changes detected, remote is already up to date.")
            return

        subprocess.run(
            ["git", "commit", "-m", f"Sync local proxies: {utc_now} UTC"],
            cwd=temp_dir,
            check=True
        )

        print("[*] Pushing updates to GitHub...")
        push_success = False
        for attempt in range(1, 4):
            push_ret = subprocess.run(["git", "push", "origin", "output"], cwd=temp_dir, capture_output=True, text=True)
            if push_ret.returncode == 0:
                push_success = True
                break
            print(f"    Push attempt {attempt} failed, retrying...")

        if push_success:
            print("\n[SUCCESS] Successfully synced to GitHub output branch!")
            print("Your phone can now update via permanent links:")
            print("  - Clash: https://raw.githubusercontent.com/grimseraph/proxies/output/clash.yaml")
            print("  - v2ray: https://raw.githubusercontent.com/grimseraph/proxies/output/v2ray.txt")
        else:
            print("\n[!] Push failed after 3 attempts due to network connection reset.")
            print("    Don't worry! You can directly transfer data/clash.yaml to your phone.")

    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)

if __name__ == "__main__":
    sync()
