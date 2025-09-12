# edge-docker-php

Ubuntu running Nginx, PHP and Node.

## Provided Software
* PHP
* Nginx
* Node & NPM (on -node variants)
* Composer

## Configuration Options
Most configuration can be done with environment variables. Here are the available options:

| Environment       | Default | Description |
| -------------     | ------- | --- |
| ENABLE_CRON       | Off     | Enables crond, add your cron jobs to /var/spool/cron/crontabs/edge. Remember to add an empty line at the end! |
| ENABLE_REDIS      | Off     | Enabled a local redis server |
| ENABLE_SSH        | Off     | Enables SSH/SFTP access to the container with user `edge` (for dev purposes only) |
| ENABLE_DEV        | Off     | Runs PHP as the `edge` user to simplify permissions (for dev purposes only) |
| SSH_PASSWORD      | -       | Set SSH password for user `edge`, required for SSH access to work |
| SSH_PORT          | 2222    | Set the port for the sshd server |
| CHISEL_PORT       | 8022    | Set the port for the chisel tunnel |
| PHP_DISPLAY_ERRORS | Off    | Display PHP errors in the browser, *not* recommended for production |
| PHP_OPCACHE_VALIDATE | On   | Forces OPcache to check for updates on every request, turn Off for production |
| PHP_TIMEZONE      | Europe/London | Specify the PHP date.timezone |
| PHP_MAX_CHILDREN  | 30      | Specify the maximum number of concurrent PHP processes |
| XDEBUG_ENABLE     | Off     | Enables the Xdebug PHP extension |
| XDEBUG_HOST       | -       | Specify the remote host Xdebug should connect to |
| WEB_ROOT          | /var/www | Set's the web server root directory |
| WEB_PUBLIC        | -       | A suffix to the WEB_ROOT to only serve files from this location |
| NEWRELIC_LICENSE  | -       | New Relic license key to enable New Relic PHP agent |
| NGINX_CONF        | default | Specify the Nginx conf file to use from `/templates/nginx-${NGINX_CONF}.conf.j2` |
| NGINX_PORT        | 8080    | Set the Nginx listening port |
| NODE_PORT         | 3000    | Set the Node listening port |
| NODE_START        | -       | Set the start command for Node web server (i.e. `npm run preview`) |
| SMTP_HOST         | smtp.mailtrap.io | Set SMTP hostname (uses MSMTP for sendmail) |
| SMTP_PORT         | 25      | Set SMTP port |
| SMTP_USER         | -       | Set SMTP username |
| SMTP_FROM         | -       | Set SMTP envelope-from header |
| SMTP_PASS         | -       | Set SMTP password |
| SMTP_TLS          | Off     | Enable TLS support, by default STARTTLS is enabled on port 587 |
| SMTP_CHECK_CERTS  | On      | Specifying *Off* will disable SMTP TLS certificate checks |

### Nginx configuration
To add custom Nginx rules, specify these in `$WEB_ROOT/nginx.conf`
