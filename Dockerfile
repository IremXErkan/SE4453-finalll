FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# SSH + temel araçlar
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd

# (Opsiyonel) root şifreyi env ile ayarla. Env verilmezse demo bir değer kullanır.
# NOT: Prod için önerilmez ama guideline istiyor diye minimumda tutuyoruz.
ENV SSH_PASSWORD="Docker123!"

# SSH config: root login + password auth açık
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

COPY init.sh /init.sh
RUN chmod +x /init.sh

# Web + SSH portları
EXPOSE 8080 2222
ENV PORT=8080

CMD ["/init.sh"]
