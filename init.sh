
set -e


mkdir -p /run/sshd /var/run/sshd


if grep -qE '^\s*#\s*Port\s+22\b' /etc/ssh/sshd_config; then
  sed -i 's/^\s*#\s*Port\s\+22\b/Port 2222/' /etc/ssh/sshd_config
elif grep -qE '^\s*Port\s+22\b' /etc/ssh/sshd_config; then
  sed -i 's/^\s*Port\s\+22\b/Port 2222/' /etc/ssh/sshd_config
elif ! grep -qE '^\s*Port\s+2222\b' /etc/ssh/sshd_config; then
  echo "Port 2222" >> /etc/ssh/sshd_config
fi


: "${SSH_PASSWORD:?SSH_PASSWORD env yok. Dockerfile'da ENV SSH_PASSWORD=... koy veya App Settings'e ekle.}"
echo "root:${SSH_PASSWORD}" | chpasswd

ssh-keygen -A


 /usr/sbin/sshd


exec gunicorn --workers 1 --timeout 180 --bind 0.0.0.0:${PORT:-8080} main:app
