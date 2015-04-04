FROM ubuntu:14.04

MAINTAINER outer/edge <hello@outeredgeuk.com>

COPY build.sh /build.sh
RUN /build.sh

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx-default /etc/nginx/conf.d/default
COPY php-fpm.conf /usr/local/etc/php-fpm.conf
COPY php.ini /usr/local/etc/php/php.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV PHP_OPCACHE Off

ONBUILD RUN composer self-update

EXPOSE 80

WORKDIR /var/www

CMD ["/usr/bin/supervisord"]