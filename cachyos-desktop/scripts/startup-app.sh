#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "KDE Desktop startup"

export KWIN_BACKEND=wayland
export XDG_SESSION_TYPE=wayland
export SWAYSOCK=${XDG_RUNTIME_DIR}/sway.socket

KDE_SWAY_CFG=$(mktemp /tmp/sway-plasma-XXXXXX.conf)
echo "output * mode ${GAMESCOPE_WIDTH:-1920}x${GAMESCOPE_HEIGHT:-1080} scale 1" > "$KDE_SWAY_CFG"
cat /etc/sway/plasma.conf >> "$KDE_SWAY_CFG"

gow_log "Env: WLR_BACKENDS=${WLR_BACKENDS:-<unset>} DISPLAY=${DISPLAY:-<unset>} WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-<unset>}"

dbus-run-session -- sway --unsupported-gpu --config "$KDE_SWAY_CFG"
gow_log "sway exited with code $?"

if [ -n "$DEBUG_SLEEP" ]; then
    gow_log "DEBUG_SLEEP: sway exited before KDE started, sleeping for investigation..."
    sleep infinity
fi
