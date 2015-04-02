FROM ubuntu:14.04

MAINTAINER outer/edge <hello@outeredgeuk.com>

COPY build.sh /build.sh
RUN /build.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx-default /etc/nginx/conf.d/default
COPY php-fpm.conf /usr/local/etc/php-fpm.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ONBUILD RUN composer self-update

EXPOSE 80

WORKDIR /var/www

CMD ["/usr/bin/supervisord"]