FROM nginx:latest

# SSH server kur
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# SSH için klasör
RUN mkdir -p /var/run/sshd

# Root şifresi (demo için; istersen değiştir)
RUN echo 'root:Docker123!' | chpasswd

# Root login + password auth aç (isteğe göre)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# init script kopyala
COPY init.sh /init.sh

# Windows'ta chmod çalışmadığı için burada veriyoruz
RUN chmod +x /init.sh

# App Service için: web + ssh portları
EXPOSE 80 2222

CMD ["/init.sh"]