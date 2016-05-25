#!/bin/bash
set -e

NGINX_VERSION=1.11.0
PHP_VERSION=7.0.6

DEBIAN_FRONTEND=noninteractive

# build apt cache
apt-get update

# install basic tools
apt-get install -y --no-install-recommends build-essential msmtp-mta python-pip=1.5.4-1 curl nano wget unzip git-core ca-certificates supervisor
pip install j2cli

# install nginx
apt-get install -y --no-install-recommends libpcre3-dev libssl-dev
mkdir /tmp/nginx
mkdir /var/www
mkdir -p /etc/nginx/conf.d
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O - | tar -zxf - -C /tmp/nginx --strip=1
cd /tmp/nginx
./configure \
    --prefix=/etc/nginx/ \
    --conf-path=/etc/nginx/nginx.conf \
    --sbin-path=/usr/sbin/nginx \
    --user=www-data \
    --group=www-data \
    --with-http_ssl_module \
    --with-http_v2_module
make -j"$(nproc)"
make install

# create custom dh params
openssl dhparam -out /etc/ssl/certs/dhparam-reduced.pem 1024
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# download and install php
apt-get install -y --no-install-recommends libcurl4-openssl-dev libreadline6-dev libmcrypt-dev libxml2-dev libpng-dev libjpeg-turbo8-dev libicu-dev libxslt1-dev
mkdir /tmp/php
mkdir -p /usr/local/etc/php/conf.d
wget http://php.net/get/php-$PHP_VERSION.tar.bz2/from/this/mirror -O - | tar -jxf - -C /tmp/php --strip=1
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
make -j"$(nproc)"
make install

# Use host as SERVER_NAME
sed -i "s/server_name/host/" /etc/nginx/fastcgi_params
sed -i "s/server_name/host/" /etc/nginx/fastcgi.conf

# install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# cleanup
apt-get purge -y build-essential g++
apt-get autoremove -y
apt-get clean
rm -rf /tmp/* /var/lib/apt/lists/*
