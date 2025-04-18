#!/bin/bash

# 设置变量（根据你的实际信息）
CF_Email="wuzhuzhan@hotmail.com"
CF_Token="MpVovOvRHHG8YRSK9BlV5Mls3g8jNzNR_mzD6sag"
DOMAIN="kk.wukobe.com"
CERT_DIR="/etc/ssl/xray"

# 安装 acme.sh
echo "[+] 安装 acme.sh ..."
curl https://get.acme.sh | sh
source ~/.bashrc

# 创建证书目录
mkdir -p "$CERT_DIR"

# 导出 Cloudflare API 环境变量
export CF_Email="$CF_Email"
export CF_Token="$CF_Token"

# 设置使用 Let's Encrypt CA
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt

# 申请证书
echo "[+] 申请证书 for $DOMAIN ..."
~/.acme.sh/acme.sh --issue --dns dns_cf -d "$DOMAIN" \
--key-file "$CERT_DIR/private.key" \
--fullchain-file "$CERT_DIR/fullchain.cer"

# 安装证书（设置自动续签 + 重启 Xray）
echo "[+] 安装证书 + 自动续签设置 ..."
~/.acme.sh/acme.sh --install-cert -d "$DOMAIN" \
--key-file "$CERT_DIR/private.key" \
--fullchain-file "$CERT_DIR/fullchain.cer" \
--reloadcmd "systemctl restart xray"

echo "[✓] 完成！证书已安装并配置自动续期 + Xray 自动重启"
