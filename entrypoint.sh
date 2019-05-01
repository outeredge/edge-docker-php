#!/bin/bash -ex

env > /etc/environment

j2 /templates/nginx-default.conf.j2 > /etc/nginx/conf.d/default.conf
j2 /templates/supervisord.conf.j2 > /etc/supervisord.conf
j2 /templates/php-fpm.conf.j2 > /etc/php7/php-fpm.conf
j2 /templates/xdebug.ini.j2 > /etc/php7/conf.d/xdebug.ini
j2 /templates/msmtprc.j2 > /etc/msmtprc

chmod -f 644 /etc/crontabs/*

if [[ $ENABLE_SSH = "On" ]]
then
    echo "edge:$SSH_PASSWORD" | chpasswd
fi

umask 002

exec "$@"