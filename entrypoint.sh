#!/bin/bash -e
j2 /etc/nginx/conf.d/default.j2.conf > /etc/nginx/conf.d/default.conf
exec "$@"