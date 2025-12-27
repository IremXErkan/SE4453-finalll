#!/bin/bash
set -e

# App Service custom container'da SSH genelde 2222'den dinlenir
sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config || true
grep -q "^Port 2222" /etc/ssh/sshd_config || echo "Port 2222" >> /etc/ssh/sshd_config

# SSH başlat
service ssh start

# Nginx'i foreground'da çalıştır (container ayakta kalsın)
nginx -g "daemon off;"