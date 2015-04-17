FROM ubuntu:14.04

MAINTAINER outer/edge <hello@outeredgeuk.com>

COPY build.sh /build.sh
RUN /build.sh

COPY entrypoint.sh /
COPY supervisord.conf /etc/supervisor/conf.d/
COPY nginx.conf /etc/nginx/
COPY default.conf.j2 /etc/nginx/templates/
COPY php-fpm.conf /usr/local/etc/
COPY php.ini /usr/local/etc/php/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV PHP_OPCACHE Off
ENV NGINX_SSL Off

ONBUILD RUN composer self-update

EXPOSE 80 443

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]