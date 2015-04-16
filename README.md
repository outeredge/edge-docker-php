# edge-docker-php
Ubuntu 14.04 running Nginx 1.7 with Pagespeed and PHP 5.6

## PHP extensions

### Ioncube
To enable ioncube, simply add the following line to your Dockerfile:

`RUN sed -i 1i"zend_extension = ioncube.so" /usr/local/etc/php/php.ini`