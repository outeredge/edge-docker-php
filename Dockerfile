FROM alpine:3.7

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/launch.sh"]

EXPOSE 80

RUN apk add --no-cache bash bash-completion ca-certificates curl git msmtp nano openssh openssh-sftp-server python sudo supervisor shadow tar unzip wget

ENV PHP_VERSION=7.1 \
    ENABLE_CRON=Off \
    ENABLE_SSH=Off \
    PHP_DISPLAY_ERRORS=Off \
    PHP_OPCACHE_VALIDATE=On \
    PHP_MAX_CHILDREN=20 \
    PHP_TIMEZONE=Europe/London \
    XDEBUG_ENABLE=Off \
    XDEBUG_HOST= \
    SMTP_HOST= \
    SMTP_PORT= \
    SMTP_USER= \
    SMTP_PASS= \
    SMTP_FROM=

RUN apk add --no-cache \
        php7=~${PHP_VERSION} \
            php7-bcmath \
            php7-ctype \
            php7-curl \
            php7-dom \
            php7-fileinfo \
            php7-fpm \
            php7-intl \
            php7-json \
            php7-mbstring \
            php7-mcrypt \
            php7-mysqli \
            php7-mysqlnd \
            php7-opcache \
            php7-openssl \
            php7-phar \
            php7-pdo_mysql \
            php7-redis \
            php7-xdebug \
            php7-simplexml \
            php7-soap \
            php7-tokenizer \
            php7-xml \
            php7-xmlreader \
            php7-xmlwriter \
            php7-xsl \
            php7-zip \
        nginx \
        nodejs \
        nodejs-npm && \
    rm -Rf /var/www/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY . /

RUN /build.sh

USER edge
