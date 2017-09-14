FROM alpine:3.6

MAINTAINER outer/edge <hello@outeredgeuk.com>

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord"]

EXPOSE 80 443

RUN apk add --no-cache --virtual .persistent-deps \
            bash \
            ca-certificates \
            curl \
            msmtp \
            nano \
            py-pip \
            tar \
            unzip \
            wget && \
    pip install --no-cache-dir shinto-cli supervisor==3.3.3

ENV NGINX_VERSION=1.13.5 \
    PHP_VERSION=7.1.9 \
    ENABLE_CRON=Off \
    PHP_DISPLAY_ERRORS=Off \
    PHP_OPCACHE_VALIDATE=On \
    PHP_MAX_CHILDREN=10 \
    PHP_TIMEZONE=Europe/London \
    NGINX_SSL=Off \
    NGINX_HSTS=Off \
    XDEBUG_ENABLE=Off \
    SMTP_HOST= \
    SMTP_PORT= \
    SMTP_USER= \
    SMTP_PASS= \
    SMTP_FROM=

COPY . /

RUN /build.sh
