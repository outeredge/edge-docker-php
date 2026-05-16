#!/bin/bash
set -e

# Load custom environment variables.
. /etc/profile.d/edge-env.sh

export SERVER_NAME="${SERVER_NAME:-:${PORT}}"
export SERVER_ROOT="${WEB_ROOT}${WEB_PUBLIC}"

# Launch supervisord unless a custom startup command is given
if [ $# -eq 0 ]; then
    set -- /usr/bin/supervisord
fi

# Execute the final command (becomes PID 1)
exec "$@"
