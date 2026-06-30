#!/bin/bash
if [ -n "$DEBUG_SLEEP" ]; then
    konsole
else
    startplasma-wayland --no-systemd
fi

swaymsg exit
