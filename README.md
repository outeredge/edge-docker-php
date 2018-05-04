# edge-docker-php
Ubuntu 16.04 running Nginx and PHP 7. Plays nicely with [dredger](https://github.com/outeredge/dredger).

## Configuration Options
Most configuration can be done with environment variables. Here are the available options;

| Environment       | Default | Description |
| -------------     | ------- | --- |
| ENABLE_CRON       | Off     | Enables crond, add your cron jobs to /etc/crontabs/edge. Remember to add an empty line at the end! |
| PHP_DISPLAY_ERRORS | Off    | Display PHP errors in the browser, *not* recommended for production |
| PHP_OPCACHE_VALIDATE | On   | Forces OPcache to check for updates on every request, turn Off for production |
| PHP_TIMEZONE      | Europe/London | Specify the PHP date.timezone |
| PHP_MAX_CHILDREN  | 10      | Specify the maximum number of concurrent PHP processes |
| XDEBUG_ENABLE     | Off     | Enables the Xdebug PHP extension with Webgrind at `/webgrind` |
| XDEBUG_HOST       | -       | Specify the remote host Xdebug should connect to |
| NGINX_SSL         | Off     | *On* - Enables HTTP/2 in Nginx |
|                   |         | *High* - Enables HTTP/2 without TLS v1.0 (for PCI DSS 3.1 Compliance) |
| NGINX_HSTS        | Off     | Enable [HSTS] (http://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) |
| SMTP_HOST         | -       | Set SMTP hostname (uses MSMTP for sendmail) |
| SMTP_PORT         | -       | Set SMTP port |
| SMTP_USER         | -       | Set SMTP username |
| SMTP_FROM         | -       | Set SMTP envelope-from header |
| SMTP_PASS         | -       | Set SMTP password |
| SMTP_TLS          | Off     | Enable TLS support, by default STARTTLS is enabled on port 587 |
| SMTP_CHECK_CERTS  | On      | Specifying *Off* will disable SMTP TLS certificate checks |

### PHP extensions & settings

Create an ini file in `/usr/local/etc/php/conf.d/`. See [here](https://github.com/outeredge/edge-docker-magento/blob/1.9.2.3/usr/local/etc/php/conf.d/magento.ini) for an example that loads the GD and soap extensions.
