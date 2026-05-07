# edge-docker-php

## Provided Software
* PHP or FrankenPHP
* Nginx (on non -frankenphp variants)
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
| PHP_DISPLAY_ERRORS | Off    | Display PHP errors in the browser, *not* recommended for production |
| PHP_OPCACHE_VALIDATE | On   | Forces OPcache to check for updates on every request, turn Off for production |
| PHP_TIMEZONE      | Europe/London | Specify the PHP date.timezone |
| PHP_MAX_CHILDREN  | 50      | Specify the maximum number of concurrent PHP processes |
| WEB_ROOT          | /var/www | Set's the web server root directory |
| WEB_PUBLIC        | -       | A suffix to the WEB_ROOT to only serve files from this location |
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

## FrankenPHP variants

In addition to the Nginx-based images above, this repo also publishes
`outeredge/edge-docker-php:8.3-frankenphp` and `:8.4-frankenphp`. These
variants run [FrankenPHP](https://frankenphp.dev/) (Caddy + PHP, single
process) and are intended for **Google Cloud Run** and similar serverless 
container platforms.

There is **no `-frankenphp-node` variant** - workflows that need Node
should continue to use the existing `8.x-node` (nginx) images.

### What's different

- Single process: FrankenPHP runs as PID 1. No supervisord, no nginx, no PHP-FPM, no cron, no SSH, no Redis sidecar, no `sudo`.
- Runs as non-root user `edge` with `CAP_NET_BIND_SERVICE` removed - cannot bind privileged ports.
- Read-only-rootfs friendly.
- Debian base image (vs Ubuntu on the nginx track).

### Configuration

Most of the env vars from the nginx track still apply. Notable changes:

| Removed                | Replacement / Note                              |
| ---------------------- | ----------------------------------------------- |
| `NGINX_CONF`           | `CADDY_CONF` - picks `/etc/caddy/conf.d/${CADDY_CONF}.caddy` |
| `NGINX_PORT`           | `PORT` (Cloud Run sets this automatically)      |
| `NODE_PORT`, `NODE_START` | No Node in this track                        |
| `ENABLE_REDIS`         | Use Memorystore or another managed Redis        |
| `ENABLE_CRON`          | Use Cloud Scheduler                             |
| `ENABLE_SSH`, `SSH_*`  | Cloud Run does not allow SSH                    |
| `ENABLE_DEV`           | Not applicable (no sudo, no arbitrary uid path) |
| `PHP_MAX_CHILDREN`     | Use `FRANKENPHP_NUM_THREADS` if needed          |

To add app-level Caddy rules, drop a file at `$WEB_ROOT/Caddyfile` - it is
imported automatically (mirrors the nginx track's `$WEB_ROOT/nginx.conf`).
