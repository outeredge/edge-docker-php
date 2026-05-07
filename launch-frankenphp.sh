#!/bin/bash

# Load custom environment variables.
. /etc/profile.d/edge-env.sh

# Cloud Run sets PORT; SERVER_NAME defaults to :$PORT so HTTPS is auto-disabled
# (Caddy treats a bare port as no hostname).
export SERVER_NAME="${SERVER_NAME:-:${PORT}}"
export SERVER_ROOT="${WEB_ROOT}${WEB_PUBLIC}"

exec frankenphp run --config /etc/caddy/Caddyfile
