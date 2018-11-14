FROM alpine:3.8

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord"]

EXPOSE 80

RUN apk add --no-cache --virtual .persistent bash ca-certificates curl git msmtp nano python tar unzip wget xz

ENV PHP_VERSION=7.1.24 \
    NGINX_VERSION=1.15.6 \
    NODE_VERSION=10.13.0 \
    SUPERVISOR_VERSION=3.3.4 \
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

COPY build.sh /
RUN /build.sh

COPY . /
