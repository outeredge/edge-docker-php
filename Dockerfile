FROM ubuntu:20.04

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/launch.sh"]

ARG DEBIAN_FRONTEND=noninteractive

ENV PHP_VERSION=7.4 \
    NODE_VERSION=14 \
    ENABLE_REDIS=Off \
    ENABLE_CRON=Off \
    ENABLE_SSH=Off \
    ENABLE_DEV=Off \
    NGINX_CONF=default \
    NGINX_PORT=8080 \
    PHP_DISPLAY_ERRORS=Off \
    PHP_OPCACHE_VALIDATE=On \
    PHP_MAX_CHILDREN=30 \
    PHP_TIMEZONE=Europe/London \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    WEB_ROOT=/var/www \
    COMPOSER_MEMORY_LIMIT=-1 \
    COMPOSER_PROCESS_TIMEOUT=600 \
    XDEBUG_ENABLE=Off \
    XDEBUG_HOST= \
    SMTP_HOST=smtp.mailtrap.io \
    SMTP_PORT=25 \
    SMTP_USER= \
    SMTP_PASS= \
    SMTP_FROM=

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        bash-completion \
        ca-certificates \
        curl \
        git \
        gnupg \
        less \
        msmtp \
        nano \
        patch \
        python3 \
        python3-pip \
        ssh \
        sudo \
        supervisor \
        unzip \
        wget

#&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*
# echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc
#rm -rf /tmp/* /var/lib/apt/lists/*

RUN apt-get install --no-install-recommends --yes gnupg

RUN . /etc/lsb-release \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu $DISTRIB_CODENAME main" >> /etc/apt/sources.list \
    && echo "deb-src http://ppa.launchpad.net/ondrej/php/ubuntu $DISTRIB_CODENAME main" >> /etc/apt/sources.list \
    && echo "deb http://ppa.launchpad.net/ondrej/nginx-mainline/ubuntu $DISTRIB_CODENAME main" >> /etc/apt/sources.list \
    && echo "deb-src http://ppa.launchpad.net/ondrej/nginx-mainline/ubuntu $DISTRIB_CODENAME main" >> /etc/apt/sources.list \
    && echo "deb https://deb.nodesource.com/node_$NODE_VERSION.x $DISTRIB_CODENAME main" >> /etc/apt/sources.list \
    && echo "deb-src https://deb.nodesource.com/node_$NODE_VERSION.x $DISTRIB_CODENAME main" >> /etc/apt/sources.list

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C 1655A0AB68576280 \
    && apt-get update

RUN apt-get install --no-install-recommends --yes \
        # PHP
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-common \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-opcache \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-xsl \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-xdebug \
        php${PHP_VERSION}-redis \
        # Other key packages
        nginx \
        nodejs \
        redis-server \
        # Cleanup
        && rm -Rf /var/www/*

#touch ~/.hushlogin
#symlink cli config to fpm config

COPY build.sh /
RUN /build.sh

COPY . /

USER edge

EXPOSE $NGINX_PORT