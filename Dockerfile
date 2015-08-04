FROM ubuntu:14.04

COPY . /

RUN /build.sh

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