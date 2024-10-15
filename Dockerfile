# Utilizar la imagen base de Ubuntu
FROM ubuntu:20.04

# Desactivar la interacción para evitar prompts durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar el sistema e instalar las dependencias necesarias
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    wget \
    curl \
    tzdata \
    sudo \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    x11-xserver-utils \
    gnome-terminal \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Establecer zona horaria a UTC para evitar prompts
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Crear un usuario llamado 'chrome-remote-user' con acceso sudo
RUN useradd -m chrome-remote-user && \
    adduser chrome-remote-user sudo && \
    echo 'chrome-remote-user:password' | chpasswd && \
    usermod -aG sudo chrome-remote-user

# Instalar Google Chrome Remote Desktop
RUN wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb && \
    dpkg --install chrome-remote-desktop_current_amd64.deb || apt-get -f install -y

# Crear el grupo 'chrome-remote-desktop' si no existe
RUN groupadd chrome-remote-desktop || true

# Añadir el usuario al grupo 'chrome-remote-desktop'
RUN usermod -aG chrome-remote-desktop chrome-remote-user

# Establecer el entorno de escritorio XFCE para Google Remote Desktop
RUN bash -c 'echo "exec /usr/bin/xfce4-session" > /home/chrome-remote-user/.xsession'

# Configurar permisos para el acceso
RUN chown -R chrome-remote-user:chrome-remote-user /home/chrome-remote-user

# Cambiar al usuario creado para Google Remote Desktop
USER chrome-remote-user

# Comando para configurar automáticamente Google Remote Desktop con un PIN
CMD /opt/google/chrome-remote-desktop/start --code="4/0AVG7fiRM_t1EAjU71n322wOzqMov9kAwnvAN5W_Wf2KnH3WRNgFfHvEp6Ia5PLPP_swE5w" --redirect-url="https://remotedesktop.google.com/" --name=$(hostname) && \
    /opt/google/chrome-remote-desktop/chrome-remote-desktop --pin=123456

# Exponer el puerto para que Google Remote Desktop pueda conectarse
EXPOSE 443
EXPOSE 80
