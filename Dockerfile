FROM ubuntu:14.04

MAINTAINER outer/edge <hello@outeredgeuk.com>

COPY build.sh /build.sh
RUN /build.sh

COPY entrypoint.sh /
COPY templates /templates/
COPY nginx /etc/nginx/
COPY php-fpm.conf /usr/local/etc/
COPY php.ini /usr/local/etc/php/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ONBUILD RUN composer self-update

ENV ENABLE_CRON=Off \
    PHP_OPCACHE=Off \
    NGINX_SSL=Off \
    NGINX_HSTS=Off \
    NGINX_PAGESPEED=Off \
    SMTP_HOST= \
    SMTP_PORT= \
    SMTP_USER= \
    SMTP_PASS= \
    SMTP_FROM=

EXPOSE 80 443

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord"]