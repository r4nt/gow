#!/usr/bin/env bash

set -e

gow_log "**** Configure default user ****"

# Remount /proc/sys as read-write to allow bubblewrap (bwrap) to check namespace limits
gow_log "Remounting /proc/sys as read-write for bubblewrap"
mount -o remount,rw /proc/sys 2>/dev/null || true

if [[ "${UNAME}" != "root" ]]; then
    PUID="${PUID:-1000}"
    PGID="${PGID:-1000}"
    UMASK="${UMASK:-000}"

    gow_log "Setting default user uid=${PUID}(${UNAME}) gid=${PGID}(${UNAME})"
    if id -u "${PUID}" &>/dev/null; then
        # need to delete the old user $PUID then change $UNAME's UID
        # default ubuntu image comes with user `ubuntu` and UID 1000
        oldname=$(id -nu "${PUID}")
        userdel -r "${oldname}"
    fi

    groupadd -f -g "${PGID}" ${UNAME}
    useradd -m -d ${HOME} -u "${PUID}" -g "${PGID}" -s /bin/bash ${UNAME}

    gow_log "Allow ${UNAME} to run sudo commands without password"
    echo "${UNAME} ALL=(ALL:ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${UNAME}"
    chmod 0440 "/etc/sudoers.d/${UNAME}"

    gow_log "Setting umask to ${UMASK}"
    umask "${UMASK}"

    gow_log "Ensure retro home directory is writable"
    chown "${PUID}:${PGID}" "${HOME}"

    gow_log "Ensure XDG_RUNTIME_DIR is writable"
    chown -R "${PUID}:${PGID}" "${XDG_RUNTIME_DIR}"
else
    gow_log "Container running as root. Nothing to do."
fi

gow_log "DONE"
