FROM cachyos/cachyos:latest AS ptrlock-builder

RUN sed -i '/^\[options\]/a DisableSandbox' /etc/pacman.conf && \
    pacman -Syu --noconfirm gcc pkgconf sdl2 && \
    pacman -Scc --noconfirm

COPY tools/ptrlock-test.c /build/ptrlock-test.c
RUN gcc -O2 -o /build/ptrlock /build/ptrlock-test.c $(sdl2-config --cflags --libs)

##############################################################################

FROM cachyos/cachyos:latest AS kwin-builder

RUN sed -i '/^\[options\]/a DisableSandbox' /etc/pacman.conf && \
    sed -i '/^\[options\]/a DisableSandboxNetwork' /etc/pacman.conf && \
    pacman -Syu --noconfirm \
        cmake extra-cmake-modules \
        kwin plasma-wayland-protocols wayland-protocols \
        vulkan-headers \
        && \
    pacman -Scc --noconfirm

WORKDIR /build

RUN curl -L https://download.kde.org/stable/plasma/6.7.2/kwin-6.7.2.tar.xz \
    | tar xJ

COPY tools/kwin-pointer-lock.patch /build/kwin-pointer-lock.patch

RUN cd kwin-6.7.2 && \
    patch -p1 < /build/kwin-pointer-lock.patch && \
    cmake -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DBUILD_TESTING=OFF \
        -DKWIN_BUILD_KCMS=OFF \
        -DKWIN_BUILD_GLOBALSHORTCUTS=OFF \
        -DVulkan_INCLUDE_DIR=/usr/include \
        -DVulkan_LIBRARY=/usr/lib/libvulkan.so.1 \
        && \
    cmake --build build --parallel "$(nproc)" --target kwin_wayland

##############################################################################

FROM cachyos/cachyos:latest

ENV \
    PUID=1000 \
    PGID=1000 \
    UMASK=000 \
    UNAME="retro" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ="Europe/London" \
    XDG_RUNTIME_DIR="/run/user/1000" \
    GOW_REQUIRED_DEVICES="/dev/input/* /dev/dri/* /dev/nvidia*"

ARG TARGETARCH TARGETVARIANT
ARG GOSU_VERSION=1.14

RUN <<_BASE
#!/bin/bash
set -e

sed -i 's/^NoProgressBar/#NoProgressBar/g' /etc/pacman.conf
sed -i '/^\[options\]/a DisableSandboxNetwork' /etc/pacman.conf
sed -i '/^\[options\]/a DisableSandbox' /etc/pacman.conf
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen

pacman -Syu --noconfirm \
    ca-certificates curl wget jq shadow sudo fuse3 \
    mesa vulkan-mesa-layers vulkan-radeon vulkan-intel vulkan-swrast libva-mesa-driver \
    egl-gbm egl-wayland \
    sway swaybg gsettings-desktop-schemas \
    xorg-xwayland \
    xdg-desktop-portal xdg-desktop-portal-kde xdg-user-dirs \
    dbus libcap procps-ng \
    plasma-meta qt6-wayland konsole fish \
    ibus bubblewrap pciutils mesa-utils lib32-mesa-utils mangohud sdl2 vim \
    steam \
    ttf-liberation ttf-dejavu

pacman -Scc --noconfirm

wget -q -O /usr/bin/gosu \
    "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}${TARGETVARIANT}"
chmod +x /usr/bin/gosu
gosu nobody true

mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"
_BASE

COPY --from=ptrlock-builder --chmod=755 /build/ptrlock /usr/local/bin/ptrlock
COPY --from=kwin-builder --chmod=755 /build/kwin-6.7.2/build/bin/kwin_wayland /usr/bin/kwin_wayland
COPY --from=kwin-builder --chmod=755 /build/kwin-6.7.2/build/bin/libkwin.so.6.7.2 /usr/lib/libkwin.so.6.7.2
RUN ln -sf libkwin.so.6.7.2 /usr/lib/libkwin.so.6
COPY --chmod=777 overlay /
COPY sway-plasma.conf /etc/sway/plasma.conf
COPY --chmod=755 scripts/kde-startup.sh /opt/gow/kde-startup.sh
COPY --chmod=777 scripts/startup-app.sh /opt/gow/startup-app.sh

ENTRYPOINT ["/entrypoint.sh"]

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
