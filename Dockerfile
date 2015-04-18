FROM ubuntu:14.04

MAINTAINER outer/edge <hello@outeredgeuk.com>

COPY build.sh /build.sh
RUN /build.sh

COPY entrypoint.sh /
COPY supervisord.conf /etc/supervisor/conf.d/
COPY nginx.conf /etc/nginx/
COPY default.j2.conf /etc/nginx/conf.d/
COPY php-fpm.conf /usr/local/etc/
COPY php.ini /usr/local/etc/php/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ONBUILD RUN composer self-update

ENV PHP_OPCACHE=Off \
    NGINX_SSL=Off \
    NGINX_HSTS=Off

EXPOSE 80 443

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]