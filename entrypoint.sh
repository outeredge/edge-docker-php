#!/bin/bash -e

j2 /templates/nginx-default.conf.j2 > /etc/nginx/conf.d/default.conf
j2 /templates/supervisord.conf.j2 > /etc/supervisor/conf.d/supervisord.conf
j2 /templates/msmtprc.j2 > /etc/msmtprc

exec "$@"