#!/bin/bash -e

echo "Preparing to launch image"

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

DOCKER_UID=`stat -c "%u" /var/www`
DOCKER_GID=`stat -c "%g" /var/www`
UID_EXISTS=`getent passwd $DOCKER_UID | cut -d: -f1`

if [ -z "${UID_EXISTS}" ]
then
    echo "Matching uid and gid to host volume"
    usermod -u $DOCKER_UID edge
    groupmod -g $DOCKER_GID edge
fi

umask 002

exec "$@"