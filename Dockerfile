FROM alpine:3.9

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord"]

EXPOSE 80

RUN apk add --no-cache bash ca-certificates curl git msmtp nano python supervisor tar unzip wget

ENV PHP_VERSION=7.2.14 \
    NGINX_VERSION=1.14.2 \
    NODE_VERSION=10.14.2 \
    ENABLE_CRON=Off \
    PHP_DISPLAY_ERRORS=Off \
    PHP_OPCACHE_VALIDATE=On \
    PHP_MAX_CHILDREN=10 \
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
            php7-fpm \
            php7-opcache \
            php7-bcmath \
            php7-intl \
            php7-mbstring \
            php7-pdo_mysql \
            php7-mysqlnd \
            php7-mysqli \
            php7-curl \
            php7-zip \
            php7-sodium \
            php7-openssl \
            php7-pecl-xdebug \
            php7-pecl-redis \
        nginx=~${NGINX_VERSION} \
        nodejs=~${NODE_VERSION} \
        npm \
        composer && \
    rm -Rf /var/www/*

COPY build.sh /
RUN /build.sh

COPY . /
