#!/bin/bash -e

env | sudo dd status=none of=/etc/environment

sudo chmod -f 644 /etc/crontabs/*

j2 /templates/nginx.conf.j2 | sudo dd status=none of=/etc/nginx/nginx.conf
j2 /templates/nginx-default.conf.j2 | sudo dd status=none of=/etc/nginx/edge.conf
j2 /templates/supervisord.conf.j2 | sudo dd status=none of=/etc/supervisord.conf
j2 /templates/php-fpm.conf.j2 | sudo dd status=none of=/etc/php5/php-fpm.conf
j2 /templates/xdebug.ini.j2 | sudo dd status=none of=/etc/php5/conf.d/xdebug.ini
j2 /templates/msmtprc.j2 | sudo dd status=none of=/etc/msmtprc

sudo /usr/bin/supervisord
