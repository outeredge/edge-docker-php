#!/bin/bash -e

if [[ -e /etc/nginx/conf.d/default.conf.j2 ]]
then
    j2 /etc/nginx/conf.d/default.conf.j2 > /etc/nginx/conf.d/default.conf
fi

exec "$@"