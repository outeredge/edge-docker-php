# Auto-load $WEB_ROOT/.env into shell sessions started via `docker exec`.
# Docker snapshots the container env at start, so PID 1's runtime mutations
# (in launch-frankenphp.sh / launch.sh) do NOT propagate to later exec'd
# processes. Sourcing here covers both login (/etc/profile) and interactive
# non-login (/etc/bash.bashrc) shells.
#
# Limitations:
#   - `docker exec <c> php …` (no shell in the chain) cannot be covered.
#     Wrap as `docker exec <c> bash -lc 'php …'`.
#   - .env is sourced as shell, so $, backticks, unquoted spaces are interpreted.
if [ -z "${CUSTOM_VARS_SET:-}" ] && [ -f "${WEB_ROOT:-/var/www}/.env" ]; then
    set -a; . "${WEB_ROOT:-/var/www}/.env"; export CUSTOM_VARS_SET=1; set +a
fi
