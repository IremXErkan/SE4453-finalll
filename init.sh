#!/bin/sh
set -e

echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] init.sh starting"

# SSH hazırlıkları (opsiyonel)
mkdir -p /run/sshd /var/run/sshd

# SSH portunu 2222 yap (varsa)
if ! grep -qE '^\s*Port\s+2222\b' /etc/ssh/sshd_config; then
  sed -i 's/^\s*#\s*Port\s\+22\b/Port 2222/' /etc/ssh/sshd_config || echo "Port 2222" >> /etc/ssh/sshd_config
fi

: "${SSH_PASSWORD:?SSH_PASSWORD env yok. Dockerfile'da ENV SSH_PASSWORD=... koy veya App Settings'e ekle.}"
echo "root:${SSH_PASSWORD}" | chpasswd

# Host anahtarları üret
ssh-keygen -A

# SSH'yi arka planda başlat (opsiyonel)
if command -v /usr/sbin/sshd >/dev/null 2>&1; then
  /usr/sbin/sshd || true &
  echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] sshd started (background)"
fi

# Azure tarafından verilen PORT'u kullan (default 8080)
PORT=${PORT:-8080}
echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] Using PORT=${PORT}"

# Exec ile gunicorn; PID1 gunicorn olur
exec gunicorn --workers 2 --timeout 180 --bind 0.0.0.0:${PORT} main:app