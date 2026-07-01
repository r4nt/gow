#!/usr/bin/env bash

set -e

gow_log "**** Configure KDE ****"

mkdir -p "${HOME}/.config"
printf '[Daemon]\nAutolock=false\n' > "${HOME}/.config/kscreenlockerrc"
chown -R "${PUID}:${PGID}" "${HOME}/.config"

gow_log "DONE"
