# Usar una imagen base de Ubuntu
FROM ubuntu:20.04

# Desactivar la interacción para evitar prompts
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    gdebi-core \
    software-properties-common \
    libgbm1 \
    libxshmfence1 \
    && apt-get clean

# Descargar el paquete de Chrome Remote Desktop
RUN wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

# Instalar el paquete .deb con gdebi para resolver dependencias
RUN gdebi -n chrome-remote-desktop_current_amd64.deb

# Instalar XFCE
RUN apt-get install -y xfce4 xfce4-goodies

# Configurar Google Remote Desktop
RUN useradd -m chrome-remote-user \
    && usermod -aG sudo chrome-remote-user \
    && echo 'chrome-remote-user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir /home/chrome-remote-user/.config \
    && echo 'exec /usr/sbin/lightdm-session "xfce4-session"' > /home/chrome-remote-user/.xsession

# Exponer los puertos necesarios
EXPOSE 8080 5900

# Comando para iniciar Google Remote Desktop
CMD ["/opt/google/chrome-remote-desktop/start"]
