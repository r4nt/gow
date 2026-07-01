#!/usr/bin/env bash

set -e

source /opt/gow/bash-lib/utils.sh

exec /opt/gow/startup-app.sh 2>&1 | tee /home/retro/startup.log
