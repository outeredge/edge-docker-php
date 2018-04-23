FROM alpine:3.7

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord"]

EXPOSE 80

RUN apk add --no-cache --virtual .persistent bash ca-certificates curl git msmtp nano python tar unzip wget xz

ENV PHP_VERSION=7.2.4 \
    NGINX_VERSION=1.13.12 \
    NODE_VERSION=8.11.1 \
    SUPERVISOR_VERSION=3.3.4 \
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

COPY build.sh /
RUN /build.sh

COPY . /
