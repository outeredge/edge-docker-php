#!/bin/bash

# Configuration: list of PHP versions to build (prod, dev and magento targets)
PHP_VERSIONS=("8.3" "8.4" "8.5")

# Configuration: map of Magento versions to their required PHP version
declare -A MAGENTO_VERSIONS=(
    ["2.4.9"]="8.4"
    ["2.4.8-p5"]="8.3"
    ["2.4.7-p10"]="8.3"
)

PROD_IMAGE="outeredge/edge-docker-php"
DEV_IMAGE="outeredge/edge-docker-php-dev"

usage() {
    cat <<EOF
Usage: ./publish.sh [--only] [target [version]]

Targets:
    <php-version>     Build prod (standard + super) images for a PHP version,
                      then the dev image and any Magento versions using it.
    dev <php-version> Build the prod base chain, then the dev image and its
                      dependent Magento versions.
    magento <version> Build the prod + dev base chain, then the Magento image.

Examples:
    ./publish.sh                  Build ALL images (prod -> dev -> magento)
    ./publish.sh 8.4              Prod 8.4 + dev 8.4 + magento 2.4.9
    ./publish.sh dev 8.3          Prod chain + dev 8.3 + magento 2.4.8-p5/2.4.7-p10
    ./publish.sh magento 2.4.9    Full chain for magento-2.4.9
    ./publish.sh --only 8.4       Only prod 8.4 (standard + super)
    ./publish.sh --only dev 8.4   Only dev 8.4 (no upstream chain or magento)
    ./publish.sh --only magento 2.4.9   Only magento-2.4.9 (needs MAGENTO_COMPOSER_AUTH)

Environment:
    DOCKER_USER / DOCKER_PASS   Docker Hub login (optional)
    MAGENTO_COMPOSER_AUTH       Required for magento targets
EOF
}

if [ ! -z "$DOCKER_PASS" ]; then
    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
fi

build_prod() {
    local php_ver=$1
    echo "Building ${PROD_IMAGE}:${php_ver}-frankenphp with Dockerfile.php${php_ver//./}-frankenphp"
    DOCKER_BUILDKIT=1 docker build --pull . -t ${PROD_IMAGE}:${php_ver}-frankenphp -f Dockerfile.php${php_ver//./}-frankenphp && \
    docker push ${PROD_IMAGE}:${php_ver}-frankenphp && \
    echo "Building ${PROD_IMAGE}:${php_ver}-frankenphp-super with Dockerfile.php${php_ver//./}-frankenphp-super" && \
    DOCKER_BUILDKIT=1 docker build --pull . -t ${PROD_IMAGE}:${php_ver}-frankenphp-super -f Dockerfile.php${php_ver//./}-frankenphp-super && \
    docker push ${PROD_IMAGE}:${php_ver}-frankenphp-super
}

build_dev() {
    local php_ver=$1
    echo "Building ${DEV_IMAGE}:${php_ver}-frankenphp with dev/Dockerfile.php${php_ver//./}-frankenphp-dev"
    DOCKER_BUILDKIT=1 docker build --pull dev/ -t ${DEV_IMAGE}:${php_ver}-frankenphp -f dev/Dockerfile.php${php_ver//./}-frankenphp-dev && \
    docker push ${DEV_IMAGE}:${php_ver}-frankenphp
}

build_magento() {
    local magento_ver=$1
    local php_ver=${MAGENTO_VERSIONS[$magento_ver]}

    if [ -z "$MAGENTO_COMPOSER_AUTH" ]; then
        echo "Warning: \$MAGENTO_COMPOSER_AUTH not set, skipping magento-${magento_ver}"
        return 0
    fi

    echo "Building ${DEV_IMAGE}:magento-${magento_ver} with dev/Dockerfile.magento-frankenphp (PHP ${php_ver})"
    DOCKER_BUILDKIT=1 docker build dev/ -t ${DEV_IMAGE}:magento-${magento_ver} \
        -f dev/Dockerfile.magento-frankenphp \
        --build-arg PHP_VERSION=${php_ver} \
        --build-arg COMPOSER_AUTH=${MAGENTO_COMPOSER_AUTH} \
        --build-arg MAGENTO_VERSION=${magento_ver} && \
    docker push ${DEV_IMAGE}:magento-${magento_ver}
}

# Build prod + dev images for a PHP version and all Magento versions that use it
publish_php() {
    local php_ver=$1
    build_prod "$php_ver" || { echo "Build failed for PHP $php_ver"; exit 1; }
    build_dev "$php_ver" || { echo "Build failed for dev PHP $php_ver"; exit 1; }
    for magento_ver in "${!MAGENTO_VERSIONS[@]}"; do
        if [ "${MAGENTO_VERSIONS[$magento_ver]}" == "$php_ver" ]; then
            build_magento "$magento_ver" || { echo "Build failed for Magento $magento_ver"; exit 1; }
        fi
    done
}

# Build dev image for a PHP version and all Magento versions that use it
publish_dev() {
    local php_ver=$1
    build_dev "$php_ver" || { echo "Build failed for dev PHP $php_ver"; exit 1; }
    for magento_ver in "${!MAGENTO_VERSIONS[@]}"; do
        if [ "${MAGENTO_VERSIONS[$magento_ver]}" == "$php_ver" ]; then
            build_magento "$magento_ver" || { echo "Build failed for Magento $magento_ver"; exit 1; }
        fi
    done
}

ONLY=0
if [ "$1" == "--only" ]; then
    ONLY=1
    shift
fi

if [ -z "$1" ]; then
    if [ $ONLY -eq 1 ]; then
        echo "No target specified for --only, exiting!"
        usage
        exit 1
    fi
    echo "No version specified, building all from configuration..."
    for php_ver in "${PHP_VERSIONS[@]}"; do
        publish_php "$php_ver"
    done
elif [ "$1" == "dev" ]; then
    if [ -z "$2" ]; then
        echo "No PHP version specified for dev target, exiting!"
        exit 1
    fi
    php_ver=$2
    if [ $ONLY -eq 1 ]; then
        build_dev "$php_ver" || { echo "Build failed for dev PHP $php_ver"; exit 1; }
    else
        publish_dev "$php_ver"
    fi
elif [ "$1" == "magento" ]; then
    if [ -z "$2" ]; then
        echo "No Magento version specified for magento target, exiting!"
        exit 1
    fi
    magento_ver=$2
    if [ -z "${MAGENTO_VERSIONS[$magento_ver]}" ]; then
        echo "Unknown Magento version: $magento_ver, exiting!"
        exit 1
    fi
    if [ $ONLY -eq 1 ]; then
        build_magento "$magento_ver" || { echo "Build failed for Magento $magento_ver"; exit 1; }
    else
        php_ver=${MAGENTO_VERSIONS[$magento_ver]}
        build_prod "$php_ver" || { echo "Build failed for PHP $php_ver"; exit 1; }
        build_dev "$php_ver" || { echo "Build failed for dev PHP $php_ver"; exit 1; }
        build_magento "$magento_ver" || { echo "Build failed for Magento $magento_ver"; exit 1; }
    fi
elif [ ! -z "${MAGENTO_VERSIONS[$1]}" ]; then
    # Argument is a known Magento version
    magento_ver=$1
    if [ $ONLY -eq 1 ]; then
        build_magento "$magento_ver" || { echo "Build failed for Magento $magento_ver"; exit 1; }
    else
        php_ver=${MAGENTO_VERSIONS[$magento_ver]}
        build_prod "$php_ver" || { echo "Build failed for PHP $php_ver"; exit 1; }
        build_dev "$php_ver" || { echo "Build failed for dev PHP $php_ver"; exit 1; }
        build_magento "$magento_ver" || { echo "Build failed for Magento $magento_ver"; exit 1; }
    fi
elif [[ " ${PHP_VERSIONS[@]} " == *" $1 "* ]]; then
    # Argument is a known PHP version
    if [ $ONLY -eq 1 ]; then
        build_prod "$1" || { echo "Build failed for PHP $1"; exit 1; }
    else
        publish_php "$1"
    fi
else
    usage
    exit 1
fi

echo "Complete!"
