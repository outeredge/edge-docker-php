FROM alpine:3.7

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/launch.sh"]

EXPOSE 80

RUN apk add --no-cache \
        bash \
        bash-completion \
        ca-certificates \
        curl \
        git \
        git-bash-completion \
        msmtp \
        nano \
        openssh \
        openssh-sftp-server \
        python \
        sudo \
        supervisor \
        shadow \
        tar \
        unzip \
        wget

ENV PHP_VERSION=5.6 \
    ENABLE_CRON=Off \
    ENABLE_SSH=Off \
    PHP_DISPLAY_ERRORS=Off \
    PHP_OPCACHE_VALIDATE=On \
    PHP_MAX_CHILDREN=20 \
    PHP_TIMEZONE=Europe/London \
    XDEBUG_ENABLE=Off \
    XDEBUG_HOST= \
    SMTP_HOST= \
    SMTP_PORT= \
    SMTP_USER= \
    SMTP_PASS= \
    SMTP_FROM=

RUN apk add --no-cache \
        php5=~${PHP_VERSION} \
            php5-bcmath \
            php5-ctype \
            php5-curl \
            php5-dom \
            php5-fpm \
            php5-iconv \
            php5-intl \
            php5-json \
            php5-mcrypt \
            php5-mysqli \
            php5-opcache \
            php5-openssl \
            php5-phar \
            php5-pdo_mysql \
            php5-soap \
            php5-xml \
            php5-xmlreader \
            php5-xsl \
            php5-zip \
            php5-zlib \
        nginx \
        nodejs \
        nodejs-npm && \
    npm install gulp-cli -g && \
    rm -Rf /var/www/* && \
    chmod g=u /etc/passwd

COPY . /

RUN /build.sh

USER edge
