#!/bin/bash -ex

# Install our php.ini override under $PHP_INI_DIR/conf.d so it loads after
# defaults. FrankenPHP/Caddy uses the CLI ini layout exclusively.
cp /templates/php.ini "$PHP_INI_DIR/conf.d/zz-edge.ini"

# Install Caddyfile and conf.d snippets
mkdir -p /etc/caddy/conf.d
cp /templates/caddy/Caddyfile /etc/caddy/Caddyfile
cp /templates/caddy/*.caddy /etc/caddy/conf.d/

# Install env-driven sendmail wrapper (msmtp)
install -m 0755 -o root -g root /templates/sendmail /usr/local/bin/sendmail
ln -sf /usr/local/bin/sendmail /usr/sbin/sendmail

# Install profile.d snippet to auto-load $WEB_ROOT/.env in docker exec shell sessions.
# /etc/profile.d/*.sh is only read by login shells, so we also append a sourcing
# line to /etc/bash.bashrc for interactive non-login shells (idempotent).
install -m 0644 -o root -g root /templates/profile.d/edge-env.sh /etc/profile.d/edge-env.sh
grep -q '/etc/profile.d/edge-env.sh' /etc/bash.bashrc \
    || echo '. /etc/profile.d/edge-env.sh' >> /etc/bash.bashrc

# Create default user (uid auto-assigned)
useradd --create-home --shell /bin/bash edge
touch /home/edge/.hushlogin
chown -Rf edge:edge ${WEB_ROOT}

# Remove default CAP_NET_BIND_SERVICE — we run as non-root and don't bind <1024.
setcap -r /usr/local/bin/frankenphp || true

# Cleanup
rm -rf /tmp/*
rm /build.sh