#!/bin/bash
set -e

# Load workspace specific environment variables.
. /etc/profile.d/00-workspace-env.sh

if [ "${XDEBUG_ENABLE:-Off}" = "On" ]; then
    XDEBUG_QUIET=1 /usr/local/bin/xdebug on
fi

exec /launch.sh "$@"