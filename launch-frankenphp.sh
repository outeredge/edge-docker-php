#!/bin/bash
set -e

# Load custom environment variables.
. /etc/profile.d/edge-env.sh

# Cloud Run sets PORT; SERVER_NAME defaults to :$PORT so HTTPS is auto-disabled
# (Caddy treats a bare port as no hostname).
export SERVER_NAME="${SERVER_NAME:-:${PORT}}"
export SERVER_ROOT="${WEB_ROOT}${WEB_PUBLIC}"

# If the first argument passed via CMD or docker run starts with `-`, 
# prepend the frankenphp run command.
if [ "${1#-}" != "$1" ]; then
    set -- frankenphp run "$@"
fi

# Execute the final command (becomes PID 1)
exec "$@"