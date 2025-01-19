# Use Kali Linux rolling release as base image
FROM kalilinux/kali-rolling

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary packages
RUN apt-get update && apt-get install -y \
    xrdp \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    xorgxrdp \
    sudo \
    systemd \
    dbus \
    dbus-user-session \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure XRDP
RUN echo "xfce4-session" > /root/.xsession

# Create user cloud_user with password 'Batman298'
RUN useradd -m -s /bin/bash cloud_user && \
    echo "cloud_user:Batman298" | chpasswd && \
    adduser cloud_user sudo

# Configure XRDP for the new user
RUN echo "xfce4-session" > /home/cloud_user/.xsession && \
    chown cloud_user:cloud_user /home/cloud_user/.xsession && \
    echo "#!/bin/bash" > /etc/xrdp/startwm.sh && \
    echo "unset DBUS_SESSION_BUS_ADDRESS" >> /etc/xrdp/startwm.sh && \
    echo "unset XDG_RUNTIME_DIR" >> /etc/xrdp/startwm.sh && \
    echo "exec startxfce4" >> /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

# Configure XRDP settings
RUN cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak && \
    sed -i 's/3389/3390/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/max_bpp=32/max_bpp=128/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/crypt_level=high/crypt_level=none/g' /etc/xrdp/xrdp.ini

# Expose XRDP port
EXPOSE 3390

# Start XRDP service
CMD service dbus start && \
    service xrdp start && \
    tail -f /dev/null 