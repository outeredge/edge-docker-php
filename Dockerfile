FROM ubuntu:14.04

MAINTAINER outer/edge <hello@outeredgeuk.com>

COPY build.sh /build.sh
RUN /build.sh

COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx-default.conf /etc/nginx/conf.d/default
COPY php-fpm.conf /usr/local/etc/php-fpm.conf
COPY php.ini /usr/local/etc/php/php.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV PHP_OPCACHE Off
ENV NGINX_SSL Off

ONBUILD RUN composer self-update

EXPOSE 80

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]