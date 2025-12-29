FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

# Sistem paketleri (SSH opsiyonel, gerekli ise bırakın)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app
COPY . .

# Entrypoint
COPY init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 8080 2222

CMD ["/init.sh"]