#!/usr/bin/env bash
set -e

# SSH portunu 2222 yap
if grep -q "^#Port 22" /etc/ssh/sshd_config; then
  sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config
fi
if ! grep -q "^Port 2222" /etc/ssh/sshd_config; then
  echo "Port 2222" >> /etc/ssh/sshd_config
fi

# Root şifreyi env'den bas
echo "root:${SSH_PASSWORD}" | chpasswd

# SSH host key yoksa üret
ssh-keygen -A

# sshd başlat
/usr/sbin/sshd

# Web’i başlat (PORT varsa onu kullan)
exec gunicorn --workers 1 --timeout 180 --bind 0.0.0.0:${PORT:-8080} main:app
