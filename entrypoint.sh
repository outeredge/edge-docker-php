#!/bin/bash -ex

env > /etc/environment

j2 /templates/nginx-default.conf.j2 > /etc/nginx/conf.d/default.conf
j2 /templates/supervisord.conf.j2 > /etc/supervisor/supervisord.conf
j2 /templates/php-fpm.conf.j2 > /usr/local/etc/php-fpm.conf
j2 /templates/xdebug.ini.j2 > /usr/local/etc/php/conf.d/xdebug.ini
j2 /templates/msmtprc.j2 > /etc/msmtprc

chmod -f 644 /etc/crontabs/*

umask 002

exec "$@"
