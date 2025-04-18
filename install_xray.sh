#!/bin/bash

# 更新系统
apt update && apt upgrade -y

# 安装必备工具
apt install -y wget curl lsof unzip sudo

# 安装 Nginx
apt install -y nginx
systemctl enable nginx
systemctl start nginx

# 安装 Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-core/releases/download/v1.7.4/Xray-linux-64.zip)" -o /tmp/xray.zip
unzip /tmp/xray.zip -d /usr/local/bin/
chmod +x /usr/local/bin/xray

# 配置 Xray
cat > /usr/local/etc/xray/config.json <<EOF
{
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "your-uuid-here",
            "alterId": 0
          }
        ],
        "disableInsecureEncryption": false
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/etc/letsencrypt/live/your-domain/fullchain.pem",
              "keyFile": "/etc/letsencrypt/live/your-domain/privkey.pem"
            }
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

# 安装 Let's Encrypt 证书
apt install -y certbot python3-certbot-nginx
certbot --nginx -d kk.wukobe.com

# 配置防火墙
ufw allow 22
ufw allow 443
ufw allow 8443
ufw enable

# 开启 BBR
echo "net.core.default_qdisc=fq" | tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | tee -a /etc/sysctl.conf
sysctl -p

# 启动 Xray
systemctl start xray
systemctl enable xray

# 配置 Telegram 推送
cat > /etc/xray/telegram.sh <<EOF
#!/bin/bash
curl -s -X POST https://api.telegram.org/bot7744320306:AAHtVp4fLqUNL-Zguen7rKOz0HQ2Ysa7qvE/sendMessage -d chat_id=7721006723 -d text="Xray 服务已启动"
EOF

chmod +x /etc/xray/telegram.sh
