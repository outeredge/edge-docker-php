#!/bin/bash -e

if [[ $ENABLE_SSH = "On" ]]
then
    echo "edge:$SSH_PASSWORD" | sudo chpasswd
fi

umask 002

exec "$@"