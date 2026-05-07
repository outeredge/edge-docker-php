#!/bin/bash

# Load custom environment variables from .env when CUSTOM_VARS_SET is empty.
# Note: Docker captures the container env at start; mutating PID 1's env here
# does NOT propagate to subsequent `docker exec` sessions. Shell exec sessions
# pick up .env independently via /etc/profile.d/edge-env.sh.
if [ -z "$CUSTOM_VARS_SET" -a -f "$WEB_ROOT/.env" ]; then
    set -a; . "$WEB_ROOT/.env"; export CUSTOM_VARS_SET=1; set +a
fi

# Cloud Run sets PORT; SERVER_NAME defaults to :$PORT so HTTPS is auto-disabled
# (Caddy treats a bare port as no hostname).
export SERVER_NAME="${SERVER_NAME:-:${PORT}}"
export SERVER_ROOT="${WEB_ROOT}${WEB_PUBLIC}"

exec frankenphp run --config /etc/caddy/Caddyfile
