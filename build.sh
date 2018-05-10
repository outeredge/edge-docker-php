#!/bin/bash -ex

apk add --no-cache --virtual .persistent-deps \
    freetype \
    icu \
    libressl \
    libxslt \
    libpng \
    libjpeg-turbo \
    libmcrypt \
    libstdc++ \
    libxml2 \
    pcre \
    py-setuptools \
    readline

apk add --no-cache --virtual .build-deps \
    autoconf \
    binutils-gold \
    coreutils \
    curl-dev \
    gcc \
    g++ \
    icu-dev \
    libc-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libressl-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    make \
    pcre-dev \
    pkgconfig \
    py-pip \
    readline-dev \
    zlib-dev

# Create user for Nginx & PHP with uid 1000 to make life easier for volume mounting
addgroup -g 1000 -S edge
adduser -u 1000 -DS -h /var/www -s /sbin/nologin -g edge -G edge edge

mkdir -p /tmp/nginx
mkdir -p /tmp/php
mkdir -p /tmp/node
mkdir -p /etc/nginx/conf.d
mkdir -p /usr/local/etc/php/conf.d
mkdir -p /etc/supervisor/conf.d
mkdir -p /var/webgrind

# Install nginx
wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O - | tar -zxf - -C /tmp/nginx --strip-components=1
cd /tmp/nginx
./configure \
    --prefix=/etc/nginx/ \
    --conf-path=/etc/nginx/nginx.conf \
    --sbin-path=/usr/sbin/nginx \
    --user=edge \
    --group=edge \
    --with-http_ssl_module \
    --with-http_v2_module
make -j "$(nproc --ignore=1)"
make install
# Use host as SERVER_NAME
sed -i "s/server_name/host/" /etc/nginx/fastcgi_params
sed -i "s/server_name/host/" /etc/nginx/fastcgi.conf

# https://github.com/docker-library/php/issues/272
export CFLAGS="-fstack-protector-strong -fpic -fpie -O2"
export CPPFLAGS="$CFLAGS"
export LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"

# Install php
wget "https://secure.php.net/distributions/php-$PHP_VERSION.tar.xz" -O - | tar -Jxf - -C /tmp/php --strip-components=1
cd /tmp/php
./configure \
    --with-config-file-path=/usr/local/etc/php \
    --with-config-file-scan-dir=/usr/local/etc/php/conf.d \
    --with-jpeg-dir=/usr/include \
    --with-png-dir=/usr/include \
    --with-freetype-dir=/usr/include \
    --with-fpm-user=edge \
    --with-fpm-group=edge \
    --disable-cgi \
    --enable-bcmath \
    --enable-fpm \
    --enable-intl \
    --enable-mbstring \
    --enable-mysqlnd \
    --enable-opcache \
    --enable-soap=shared \
    --enable-zip \
    --with-curl \
    --with-openssl \
    --with-zlib \
    --with-pdo-mysql \
    --with-mcrypt=shared \
    --with-gd=shared \
    --with-xsl=shared
make -j "$(nproc --ignore=1)"
make install
rm -rf /usr/local/bin/phpdbg

# Install node, npm
wget "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" -O - | tar -Jxf - -C /tmp/node --strip-components=1
cd /tmp/node
./configure
make -j "$(nproc --ignore=1)"
make install

# Install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install xdebug, phpredis
pecl update-channels
pecl install xdebug redis

# Install webgrind
wget "https://github.com/jokkedk/webgrind/archive/v1.5.0.tar.gz" -O - | tar -zxf - -C /var/webgrind --strip-components=1
chown edge:edge -R /var/webgrind

# Install supervisor, shinto-cli
pip install --no-cache-dir shinto-cli supervisor==$SUPERVISOR_VERSION

# Download ioncube loaders
SV=(${PHP_VERSION//./ })
IONCUBE_VERSION="${SV[0]}.${SV[1]}"
wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O - | tar -zxf - -C /tmp
cp /tmp/ioncube/ioncube_loader_lin_$IONCUBE_VERSION.so $(php-config --extension-dir)/ioncube.so

# Replace sendmail with msmtp
ln -sf /usr/bin/msmtp /usr/sbin/sendmail

# Cleanup
apk del .build-deps
rm -rf /tmp/*
