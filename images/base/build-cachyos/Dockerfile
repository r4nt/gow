# syntax=docker/dockerfile:1.4
FROM cachyos/cachyos:latest

# Configure default user and set env
# The users UID and GID will be set on container startup
ENV \
    PUID=1000 \
    PGID=1000 \
    UMASK=000 \
    UNAME="retro" \
    HOME="/home/retro" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ="Europe/London"

ARG TARGETARCH TARGETVARIANT

# Install default required packages
ARG GOSU_VERSION=1.14

RUN <<_INSTALL_PACKAGES
#!/bin/bash
set -e

echo "**** Update package manager ****" \
    && sed -i 's/^NoProgressBar/#NoProgressBar/g' /etc/pacman.conf \
    && echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

echo "**** Configure locals ****" \
    && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
    && locale-gen

echo "**** Install certificates ****" \
    && pacman -Syu --noconfirm --needed \
    ca-certificates

echo "**** Section cleanup ****" \
    && pacman -Scc --noconfirm \
    && rm -fr /var/lib/pacman/sync/* \
    && rm -fr /var/cache/pacman/pkg/*

echo "**** Disable pacman sandboxed network for container builds ****"
sed -i '/^\[options\]/a DisableSandboxNetwork' /etc/pacman.conf

echo "**** Install base packages ****"
pacman -Syu --noconfirm \
        ca-certificates \
        fuse3 \
        wget \
        curl \
        jq \
        shadow \
        sudo

echo "**** Install fonts ****"
pacman -S --noconfirm ttf-liberation ttf-dejavu xorg-fonts-misc

echo "**** Install gosu ****"
wget --progress=dot:giga \
    -O /usr/bin/gosu \
    "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}${TARGETVARIANT}"
chmod +x /usr/bin/gosu

echo "**** Verify gosu works ****"
gosu nobody true && echo "Working!"

echo "**** Section cleanup ****" \
    && pacman -Scc --noconfirm \
    && rm -fr /home/default/.cache/yay \
    && rm -fr /var/lib/pacman/sync/* \
    && rm -fr /var/cache/pacman/pkg/* \
    && rm -rf /tmp/yay*

echo
_INSTALL_PACKAGES

# Import overlay
COPY overlay /

# Set entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
