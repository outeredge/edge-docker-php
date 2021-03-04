#!/bin/bash

# Change user ID of edge to match the arbitrary ID given to the container with -u
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
     sed "s/^edge:x:1000:1000:/edge:x:$(id -u):1000:/" /etc/passwd > /tmp/passwd
     cat /tmp/passwd > /etc/passwd
     rm /tmp/passwd
     sudo groupadd arbitary -g $(id -u)
     sudo usermod -aG arbitary edge
     sudo chown -R edge /home/edge /var/www
  fi
fi

umask 002

exec "$@"