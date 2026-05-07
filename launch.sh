#!/bin/bash

export USER=$(whoami)

if [ "$ENABLE_DEV" = "On" ]; then
    sudo chown -Rf $USER:$USER /var/log/nginx
else
    sudo chmod g=r /etc/passwd
fi

# Generate unique SSH host keys and set SSH password per container
if [ "$ENABLE_SSH" = "On" ]; then
    sudo mkdir -p /var/run/sshd
    sudo ssh-keygen -A
    echo "edge:$SSH_PASSWORD" | sudo chpasswd
fi

# Load custom environment variables
. /etc/profile.d/edge-env.sh

env | sudo dd status=none of=/etc/environment

sudo chmod -f 600 /var/spool/cron/crontabs/*

j2 /templates/nginx.conf.j2 | sudo dd status=none of=/etc/nginx/nginx.conf
j2 /templates/nginx-${NGINX_CONF}.conf.j2 | sudo dd status=none of=/etc/nginx/conf.d/${NGINX_CONF}.conf
j2 /templates/supervisord.conf.j2 | sudo dd status=none of=/etc/supervisord.conf
j2 /templates/php-fpm.conf.j2 | sudo dd status=none of=/etc/php/${PHP_VERSION}/fpm/php-fpm.conf
for f in /templates/*.ini.j2; do j2 $f | sudo dd status=none of=/etc/php/${PHP_VERSION}/fpm/conf.d/$(basename -s .j2 $f); done

chmod o+w /dev/stdout

sudo -E /usr/bin/supervisord
