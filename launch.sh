#!/bin/bash
set -e

# Load custom environment variables.
. /etc/profile.d/edge-env.sh

export SERVER_NAME="${SERVER_NAME:-:${PORT}}"
export SERVER_ROOT="${WEB_ROOT}${WEB_PUBLIC}"

if command -v supervisord >/dev/null 2>&1; then
    # Launch supervisord unless a custom startup command is given
    if [ $# -eq 0 ]; then
        set -- /usr/bin/supervisord
    fi
else
    # If no arguments are passed, default to running FrankenPHP with our config
    if [ $# -eq 0 ]; then
        set -- frankenphp run --config /etc/caddy/Caddyfile
    # If arguments are passed but they are flags (e.g. --watch), prepend the run command
    elif [ "${1#-}" != "$1" ]; then
        set -- frankenphp run --config /etc/caddy/Caddyfile "$@"
    fi
fi

# Execute the final command (becomes PID 1)
exec "$@"