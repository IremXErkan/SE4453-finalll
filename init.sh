#!/usr/bin/env bash
set -e

# SSH portunu 2222 yap
if grep -q "^#Port 22" /etc/ssh/sshd_config; then
  sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config
fi
if ! grep -q "^Port 2222" /etc/ssh/sshd_config; then
  echo "Port 2222" >> /etc/ssh/sshd_config
fi

# SSH için gerekli klasör
mkdir -p /var/run/sshd

# SSH başlat
/usr/sbin/sshd

# Web (gunicorn) başlat
exec "$@"
