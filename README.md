# edge-docker-php
Ubuntu 14.04 running Nginx 1.7 with Pagespeed and PHP 5.6

## Configuration Options
Most configuration can be done with environment variables. Here are the available options;

| Environment       | Default | Description |
| -------------     | ------- | --- |
| ENABLE_CRON       | Off     | Enables crond, add your cron jobs to /etc/crontab |
| PHP_OPCACHE       | Off     | Enables PHP OPcache extension |
| NGINX_SSL         | Off     | Enables HTTPS in Nginx with SPDY |
| NGINX_SSL_REDUCED | -       | Adds additional cipher suites that allow older (i.e. Java7) clients to connect |
| NGINX_HSTS        | Off     | Enable [HSTS] (http://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) |
| NGINX_PAGESPEED   | Off     | Enable ngx_pagespeed extension |
| SMTP_HOST         | -       | Set SMTP hostname (uses MSMTP for sendmail) | 
| SMTP_PORT         | -       | Set SMTP port |
| SMTP_USER         | -       | Set SMTP username/SMTP from |
| SMTP_PASS         | -       | Set SMTP password |

## PHP extensions

### Ioncube
To enable ioncube, simply add the following line to your Dockerfile:

`RUN sed -i 1i"zend_extension = ioncube.so" /usr/local/etc/php/php.ini`
