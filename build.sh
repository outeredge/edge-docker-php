#!/bin/bash -ex

apk add --no-cache --virtual .build-deps \
    autoconf \
    coreutils \
    curl-dev \
    gcc \
    g++ \
    icu-dev \
    libc-dev \
    libjpeg-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libressl \
    libressl-dev \
    libxml2-dev \
    libxslt-dev \
    make \
    pcre-dev \
    readline-dev \
    zlib-dev

addgroup -g 82 -S www-data
adduser -u 82 -D -S -G www-data www-data

mkdir -p /tmp/nginx
mkdir -p /tmp/php
mkdir -p /etc/nginx/conf.d
mkdir -p /usr/local/etc/php/conf.d
mkdir -p /var/www
mkdir -p /var/webgrind

wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O - | tar -zxf - -C /tmp/nginx --strip-components=1
cd /tmp/nginx
./configure \
    --prefix=/etc/nginx/ \
    --conf-path=/etc/nginx/nginx.conf \
    --sbin-path=/usr/sbin/nginx \
    --user=www-data \
    --group=www-data \
    --with-http_ssl_module \
    --with-http_v2_module
make -j "$(nproc)"
make install
# Use host as SERVER_NAME
sed -i "s/server_name/host/" /etc/nginx/fastcgi_params
sed -i "s/server_name/host/" /etc/nginx/fastcgi.conf

wget https://secure.php.net/distributions/php-$PHP_VERSION.tar.bz2 -O - | tar -jxf - -C /tmp/php --strip-components=1
cd /tmp/php
./configure \
    --with-config-file-path=/usr/local/etc/php \
    --with-config-file-scan-dir=/usr/local/etc/php/conf.d \
    --with-jpeg-dir=/usr \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --disable-cgi \
    --enable-fpm \
    --enable-intl \
    --enable-mbstring \
    --enable-mysqlnd \
    --enable-opcache \
    --enable-soap=shared \
    --enable-zip \
    --with-curl \
    --with-openssl \
    --with-readline \
    --with-zlib \
    --with-pdo-mysql \
    --with-mcrypt=shared \
    --with-gd=shared \
    --with-xsl=shared
make -j "$(nproc)"
make install

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

pecl update-channels
pecl install xdebug redis

wget https://github.com/jokkedk/webgrind/archive/v1.5.0.tar.gz -O - | tar -zxf - -C /var/webgrind
chown www-data:www-data -R /var/webgrind

apk del .build-deps
rm -rf /tmp/*