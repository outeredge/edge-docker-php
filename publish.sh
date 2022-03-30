#!/bin/bash

if [ -z "$1" ]; then
    echo "No version specified, exiting!"
    exit
fi;

echo "Building image outeredge/edge-docker-php:$1"
docker build --pull . -t outeredge/edge-docker-php:$1 -f Dockerfile.php81 --no-cache
docker push outeredge/edge-docker-php:$1
echo "Complete!"
