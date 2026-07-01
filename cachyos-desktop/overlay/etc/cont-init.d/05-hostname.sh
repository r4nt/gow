#!/usr/bin/env bash

set -e

HOSTNAME="${CONTAINER_HOSTNAME:-cachyos-desktop}"

gow_log "**** Setting hostname to ${HOSTNAME} ****"
echo "$HOSTNAME" > /proc/sys/kernel/hostname
echo "$HOSTNAME" > /etc/hostname
