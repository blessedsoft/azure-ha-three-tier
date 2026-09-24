#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y nginx

cat >/etc/nginx/sites-available/default <<NGINX
server {
  listen 80 default_server;

  location = /health {
    access_log off;
    return 200 "ok\n";
    add_header Content-Type text/plain;
  }

  location / {
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_pass http://${app_internal_ip}:${app_port};
  }
}
NGINX

systemctl enable nginx
systemctl restart nginx
