#!/bin/bash

export USER=$(whoami)

if [ "$ENABLE_DEV" = "On" ]; then
    sudo chown -Rf $USER:$USER /var/log/php
    sudo chown -Rf $USER:$USER /var/log/nginx
else
    sudo chmod g=r /etc/passwd
fi

# Set SSH password
if [ "$ENABLE_SSH" = "On" ]; then
    echo "edge:$SSH_PASSWORD" | sudo chpasswd
fi

# Load custom environment variables from .env when CUSTOM_VARS_SET is empty
if [ -z "$CUSTOM_VARS_SET" -a -f "$WEB_ROOT/.env" ]; then
    set -a; . $WEB_ROOT/.env; export CUSTOM_VARS_SET=1; set +a
fi

env | sudo dd status=none of=/etc/environment

sudo chmod -f 644 /etc/crontabs/*

j2 /templates/nginx.conf.j2 | sudo dd status=none of=/etc/nginx/nginx.conf
j2 /templates/nginx-${NGINX_CONF}.conf.j2 | sudo dd status=none of=/etc/nginx/conf.d/${NGINX_CONF}.conf
j2 /templates/supervisord.conf.j2 | sudo dd status=none of=/etc/supervisord.conf
j2 /templates/php-fpm.conf.j2 | sudo dd status=none of=/etc/php/${PHP_VERSION}/fpm/php-fpm.conf
j2 /templates/msmtprc.j2 | sudo dd status=none of=/etc/msmtprc
for f in /templates/*.ini.j2; do j2 $f | sudo dd status=none of=/etc/php/${PHP_VERSION}/fpm/conf.d/$(basename -s .j2 $f); done

chmod o+w /dev/stdout

sudo /usr/bin/supervisord
