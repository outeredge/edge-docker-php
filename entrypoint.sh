#!/bin/bash -e

if [[ -e /etc/nginx/conf.d/default.conf.j2 ]]
then
    j2 /etc/nginx/conf.d/default.conf.j2 > /etc/nginx/conf.d/default.conf
fi

if [[ -e /etc/supervisor/conf.d/supervisord.conf.j2 ]]
then
    j2 /etc/supervisor/conf.d/supervisord.conf.j2 > /etc/supervisor/conf.d/supervisord.conf
fi

exec "$@"