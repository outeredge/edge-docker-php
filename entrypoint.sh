#!/bin/bash -e
j2 /etc/nginx/templates/default.conf.j2 > /etc/nginx/conf.d/default
exec "$@"