#!/bin/bash

if [ -z "$1" ]; then
    echo "No version specified, exiting!"
    exit
fi;

if [ ! -z "$DOCKER_PASS" ]; then
    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
fi;

DOCKER_BUILDKIT=1 docker build --pull . -t outeredge/edge-docker-php:$1-frankenphp -f Dockerfile.php${1//./}-frankenphp && \
docker push outeredge/edge-docker-php:$1-frankenphp && \
echo "Complete!"
