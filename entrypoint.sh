#!/bin/bash -e
j2 /etc/nginx/conf.d/default
exec "$@"