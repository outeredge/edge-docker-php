#!/bin/bash
set -e

# Load custom environment variables.
. /etc/profile.d/edge-env.sh

export SERVER_NAME="${SERVER_NAME:-:${PORT}}"
export SERVER_ROOT="${WEB_ROOT}${WEB_PUBLIC}"

# If no arguments are passed, default to running FrankenPHP with our config
if [ $# -eq 0 ]; then
    set -- frankenphp run --config /etc/caddy/Caddyfile
# If arguments are passed but they are flags (e.g. --watch), prepend the run command
elif [ "${1#-}" != "$1" ]; then
    set -- frankenphp run --config /etc/caddy/Caddyfile "$@"
fi

# Execute the final command (becomes PID 1)
exec "$@"