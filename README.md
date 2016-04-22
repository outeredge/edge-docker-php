# edge-docker-php
Ubuntu 14.04 running Nginx 1.9 and PHP 5.6. Plays nicely with [dredger](https://github.com/outeredge/dredger).

## Configuration Options
Most configuration can be done with environment variables. Here are the available options;

| Environment       | Default | Description |
| -------------     | ------- | --- |
| ENABLE_CRON       | Off     | Enables crond, add your cron jobs to /etc/crontab |
| PHP_OPCACHE_VALIDATE | On   | Forces OPcache to check for updates on every request, turn Off for production |
| PHP_TIMEZONE      | Europe/London | Specify the PHP date.timezone |
| PHP_MAX_CHILDREN  | 30      | Specify the maximum number of concurrent PHP processes |
| NGINX_SSL         | Off     | *On* - Enables HTTP/2 in Nginx |
|                   |         | *Reduced* - Enables HTTP/2 with support for older (i.e. Java7) clients |
|                   |         | *High* - Enables HTTP/2 without TLS v1.0 (for PCI DSS 3.1 Compliance) |
| NGINX_HSTS        | Off     | Enable [HSTS] (http://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) |
| SMTP_HOST         | -       | Set SMTP hostname (uses MSMTP for sendmail) |
| SMTP_PORT         | -       | Set SMTP port |
| SMTP_USER         | -       | Set SMTP username |
| SMTP_FROM         | -       | Set SMTP envelope-from header |
| SMTP_PASS         | -       | Set SMTP password |
| SMTP_CHECK_CERTS  | On      | Specifying *Off* will disable SMTP TLS certificate checks |

## PHP extensions

### Ioncube
To enable ioncube, simply add the following line to your Dockerfile:

`RUN sed -i 1i"zend_extension = ioncube.so" /usr/local/etc/php/php.ini`
