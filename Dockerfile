FROM alpine:3.11

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
        patch \
        py2-pip \
        sudo \
        supervisor \
        shadow \
        tar \
        unzip \
        wget

ENV PHP_VERSION=7.3 \
    ENABLE_CRON=Off \
    ENABLE_SSH=Off \
    NGINX_CONF=default \
    PHP_DISPLAY_ERRORS=Off \
    PHP_OPCACHE_VALIDATE=On \
    PHP_MAX_CHILDREN=20 \
    PHP_TIMEZONE=Europe/London \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    WEB_ROOT=/var/www \
    XDEBUG_ENABLE=Off \
    XDEBUG_HOST= \
    SMTP_HOST=smtp.mailtrap.io \
    SMTP_PORT=25 \
    SMTP_USER= \
    SMTP_PASS= \
    SMTP_FROM=

RUN apk add --no-cache \
        php7=~${PHP_VERSION} \
            php7-bcmath \
            php7-ctype \
            php7-curl \
            php7-dom \
            php7-fileinfo \
            php7-fpm \
            php7-iconv \
            php7-intl \
            php7-mbstring \
            php7-mysqli \
            php7-mysqlnd \
            php7-opcache \
            php7-openssl \
            php7-pcntl \
            php7-pdo_mysql \
            php7-pecl-redis \
            php7-pecl-xdebug \
            php7-simplexml \
            php7-soap \
            php7-sodium \
            php7-tokenizer \
            php7-xml \
            php7-xmlreader \
            php7-xmlwriter \
            php7-xsl \
            php7-zip \
        composer \
        nginx \
        nodejs \
        npm && \
    npm install gulp-cli -g && \
    rm -Rf /var/www/* && \
    chmod g=u /etc/passwd && \
    echo 'Set disable_coredump false' > /etc/sudo.conf

COPY . /

RUN /build.sh

USER edge
