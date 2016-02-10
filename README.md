# edge-docker-php
Ubuntu 14.04 running Nginx 1.9 with Pagespeed and PHP 7.0. Plays nicely with [dredger](https://github.com/outeredge/dredger).

## Configuration Options
Most configuration can be done with environment variables. Here are the available options;

| Environment       | Default | Description |
| -------------     | ------- | --- |
| ENABLE_CRON       | Off     | Enables crond, add your cron jobs to /etc/crontab |
| PHP_OPCACHE       | Off     | Enables PHP OPcache extension |
| NGINX_SSL         | Off     | *On* - Enables HTTPS2 in Nginx |
|                   |         | *Reduced* - Enables HTTPS with support for older (i.e. Java7) clients |
|                   |         | *High* - Enables HTTPS without TLS v1.0 (for PCI DSS 3.1 Compliance) |
| NGINX_HSTS        | Off     | Enable [HSTS] (http://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) |
| NGINX_PAGESPEED   | Off     | Enable ngx_pagespeed extension |
| SMTP_HOST         | -       | Set SMTP hostname (uses MSMTP for sendmail) |
| SMTP_PORT         | -       | Set SMTP port |
| SMTP_USER         | -       | Set SMTP username |
| SMTP_FROM         | -       | Set SMTP envelope-from header |
| SMTP_PASS         | -       | Set SMTP password |
| SMTP_CHECK_CERTS  | On      | Specifying *Off* will disable SMTP TLS certificate checks |

### PHP extensions & settings

Create an ini file in `/usr/local/etc/php/conf.d/`. See [here](https://github.com/outeredge/edge-docker-magento/blob/1.9.2.3/usr/local/etc/php/conf.d/magento.ini) for an example that loads the GD and soap extensions.