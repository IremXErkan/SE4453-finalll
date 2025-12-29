
set -e

echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] init.sh starting"


mkdir -p /run/sshd /var/run/sshd


if ! grep -qE '^\s*Port\s+2222\b' /etc/ssh/sshd_config; then
  sed -i 's/^\s*#\s*Port\s\+22\b/Port 2222/' /etc/ssh/sshd_config || echo "Port 2222" >> /etc/ssh/sshd_config
fi

: "${SSH_PASSWORD:?SSH_PASSWORD env yok. Dockerfile'da ENV SSH_PASSWORD=... koy veya App Settings'e ekle.}"
echo "root:${SSH_PASSWORD}" | chpasswd


ssh-keygen -A


if command -v /usr/sbin/sshd >/dev/null 2>&1; then
  /usr/sbin/sshd || true &
  echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] sshd started (background)"
fi


PORT=${PORT:-8080}
echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] Using PORT=${PORT}"


exec gunicorn --workers 2 --timeout 180 --bind 0.0.0.0:${PORT} main:app