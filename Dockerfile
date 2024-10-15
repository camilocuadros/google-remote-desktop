#
# Example build command:  docker build --pull --tag DOCKERHUB-USERNAME/chrome-remote-desktop:ubuntu-xfce --build-arg CODE=4/0AZE....jyuw .
#
FROM amd64/ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
# INSTALL XFCE AND OTHER PACKAGES
RUN apt-get update && apt-get upgrade --assume-yes
RUN apt-get install --assume-yes --fix-missing sudo wget apt-utils xvfb xfce4 xbase-clients \
    desktop-base vim python3-psutil psmisc python3-psutil xserver-xorg-video-dummy \
    libutempter0 epiphany-browser
# INSTALL GOOGLE REMOTE DESKTOP
RUN wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
RUN dpkg --install chrome-remote-desktop_current_amd64.deb
RUN echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session
# ----------------------------------------------------------
# SPECIFY VARIABLES FOR SETTING UP CHROME REMOTE DESKTOP
# Code from https://remotedesktop.google.com/headless > Begin > Next > Authorize
# Each code can only be used to build once.
ARG CODE=4/0AVG7fiRhHSM-CymPiaECHR_mxWxI52ooJ3X_kaPyJKednAmv3JsDNnbP2r9Dv_aj9Dv7lA
# pin must be 6 digits
ARG PIN=123456
ARG USER=user
ARG HOSTNAME=chrome-remote-desktop
# ----------------------------------------------------------
RUN test -n "$CODE" || (echo "ERROR: argument CODE is not set" && false)
# ADD USER TO THE SPECIFIED GROUPS
RUN useradd --create-home --groups chrome-remote-desktop "$USER"
RUN echo "$USER  ALL=(ALL)  NOPASSWD:ALL" >> /etc/sudoers.d/$USER
USER $USER
RUN mkdir -p ~/.config/chrome-remote-desktop
# INSTALL GOOGLE'S CHROME REMOTE DESKTOP WITH CODE, HOSTNAME AND PIN FROM ENV VAR
# When this fails with error 'No host config file found.' generate a new code using https://remotedesktop.google.com/headless
RUN DISPLAY= /opt/google/chrome-remote-desktop/start-host --code=$CODE \
    --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name="$HOSTNAME" --pin=$PIN
RUN cp ~/.config/chrome-remote-desktop/host#*.json ~/.config/chrome-remote-desktop/host.json
RUN sudo service chrome-remote-desktop stop
# COPY CONFIG TO CONFIG FOR CURRENT HOSTNAME AND START CHROME REMOTE DESKTOP
CMD [ "/bin/bash","-c","ln -s ~/.config/chrome-remote-desktop/host.json ~/.config/chrome-remote-desktop/host#$( echo -n $HOSTNAME | md5sum | cut -c -32).json; /opt/google/chrome-remote-desktop/chrome-remote-desktop --start --foreground"]
