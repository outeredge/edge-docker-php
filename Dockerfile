FROM alpine:3.7

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/launch.sh"]

RUN apk add --no-cache \
        bash \
        bash-completion \
        ca-certificates \
        curl \
        findutils \
        git \
        git-bash-completion \
        msmtp \
        nano \
        openssh \
        openssh-sftp-server \
        py2-pip \
        sudo \
        supervisor \
        shadow \
        tar \
        unzip \
        wget

ENV PHP_VERSION=5.6 \
    ENABLE_CRON=Off \
    ENABLE_SSH=Off \
    ENABLE_DEV=Off \
    NGINX_CONF=default \
    NGINX_PORT=80 \
    PHP_DISPLAY_ERRORS=Off \
    PHP_OPCACHE_VALIDATE=On \
    PHP_MAX_CHILDREN=20 \
    PHP_TIMEZONE=Europe/London \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    WEB_ROOT=/var/www \
    XDEBUG_ENABLE=Off \
    XDEBUG_HOST= \
    SMTP_HOST=smtp.mailtrap.io \
    SMTP_PORT=25 \
    SMTP_USER= \
    SMTP_PASS= \
    SMTP_FROM=

RUN apk add --no-cache \
        php5=~${PHP_VERSION} \
            php5-bcmath \
            php5-ctype \
            php5-curl \
            php5-dom \
            php5-fpm \
            php5-iconv \
            php5-intl \
            php5-json \
            php5-mcrypt \
            php5-mysqli \
            php5-opcache \
            php5-openssl \
            php5-phar \
            php5-pdo_mysql \
            php5-soap \
            php5-xml \
            php5-xmlreader \
            php5-xsl \
            php5-zip \
            php5-zlib \
        nginx \
        nodejs \
        nodejs-npm && \
    npm install gulp-cli -g && \
    npm cache clean --force && \
    rm -Rf /var/www/*

COPY . /

RUN /build.sh

USER edge

EXPOSE $NGINX_PORT