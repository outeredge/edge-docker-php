#!/bin/bash -e

if [[ $ENABLE_SSH = "On" ]]
then
    echo "edge:$SSH_PASSWORD" | sudo chpasswd
fi

DOCKER_UID=`stat -c "%u" /var/www`
DOCKER_GID=`stat -c "%g" /var/www`
UID_EXISTS=`getent passwd $DOCKER_UID | cut -d: -f1`

if [ -z "${UID_EXISTS}" ]
then
    sudo usermod -u $DOCKER_UID edge
    sudo groupmod -g $DOCKER_GID edge
    chown -R edge:edge /var/www /home/edge
fi

umask 002

exec "$@"