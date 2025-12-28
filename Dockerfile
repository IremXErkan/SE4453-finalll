FROM python:3.11-slim

# SSH için
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd

# Root şifresi (demo)
 RUN echo 'root:Docker123!' | chpasswd 


 
# Root login + password auth aç
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Kodları kopyala
COPY . .

# init script
COPY init.sh /init.sh
RUN chmod +x /init.sh

# Web + SSH portları
EXPOSE 8080 2222
ENV PORT=8080

# SSH + Flask(Gunicorn)
CMD ["/init.sh", "gunicorn", "--bind", "0.0.0.0:8080", "main:app"]
