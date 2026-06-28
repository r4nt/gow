ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:cachyos

######################################
# The issue here is, that you don't want to give privileged,
# but bwrap needs CAP_SYS_ADMIN.
# However if you explicitly give CAP_SYS_ADMIN, bwrap throws an error,
# because it detects that capabilities have been tempered with
FROM ${BASE_APP_IMAGE} AS bwrap-builder

WORKDIR /root
COPY ignore_capabilities.patch /root/
RUN pacman -Syu --noconfirm git meson ninja ca-certificates libcap gcc make pkgconf && \
    git clone https://github.com/containers/bubblewrap && \
    cd bubblewrap && \
    patch -p1 < ../ignore_capabilities.patch && \
    meson setup _builddir && \
    meson compile -C _builddir

######################################

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

RUN <<_INSTALL_STEAM
#!/bin/bash
set -e

# Update and install Steam
pacman -Syu --noconfirm steam

# Additional packages
pacman -S --noconfirm networkmanager bluez ibus polkit file pciutils lsb-release zenity cachyos-gaming-meta lib32-mesa-utils mesa-utils flatpak vim

# Cleanup
# We'll be using a custom steam startup script, the default `steam` script was failing
rm -f $(which steam)
rm -f /usr/bin/zenity && ln -s /usr/bin/true /usr/bin/zenity
pacman -Scc --noconfirm
_INSTALL_STEAM

# create symlink for improved decky loader compatibility
RUN ln -sf "$HOME" /home/deck

# Bake Decky Loader at build time. Previously system-services.sh fetched
# the latest release on every container start via api.github.com, which
# rate-limited (60 unauth req/h per IP) and broke cont-init smoke tests
# and fresh-user logins non-deterministically. Pinning + baking removes
# the runtime API dependency. Bump DECKY_LOADER_VERSION to update.
ARG DECKY_LOADER_VERSION=v3.2.3
# --retry-all-errors covers HTTP 4xx/5xx (curl --retry alone only retries
# transport-layer errors). The release-asset CDN occasionally returns 4xx
# briefly; without this flag, curl exits 22 on the first hit and fails the
# build. --retry-max-time bounds the overall wait.
RUN mkdir -p /opt/decky && \
    curl -fsSL --retry 5 --retry-all-errors --retry-delay 2 --retry-max-time 60 \
      -o /opt/decky/PluginLoader \
      "https://github.com/SteamDeckHomebrew/decky-loader/releases/download/${DECKY_LOADER_VERSION}/PluginLoader" && \
    chmod 755 /opt/decky/PluginLoader

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/system-services.sh /etc/cont-init.d/system-services.sh
COPY --chmod=777 steamos-update /usr/bin/steamos-update
COPY --chmod=777 steamos-update /usr/bin/steamos-polkit-helpers/steamos-update
COPY --chmod=777 steamos-session-select /usr/bin/steamos-session-select
COPY --chmod=777 jupiter-biosupdate /usr/bin/jupiter-biosupdate
COPY --chmod=777 jupiter-biosupdate /usr/bin/steamos-polkit-helpers/jupiter-biosupdate
COPY --chmod=777 scripts/steamos-dbus-watchdog.sh /usr/local/bin/steamos-dbus-watchdog.sh
COPY --chmod=777 scripts/steam.sh /usr/bin/steam
COPY --from=bwrap-builder --chmod=4755 /root/bubblewrap/_builddir/bwrap /usr/bin/bwrap

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
