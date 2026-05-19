# edge-docker-php

## Provided Software
* FrankenPHP (PHP + Caddy)
* Composer

## Configuration Options
Most configuration can be done with environment variables. Here are some of the available non-standard options:

| Environment       | Default | Description |
| -------------     | ------- | --- |
| PHP_DISPLAY_ERRORS | Off    | Display PHP errors in the browser, *not* recommended for production |
| PHP_OPCACHE_VALIDATE | Off   | Forces OPcache to check for updates on every request, turn Off for production |
| PHP_TIMEZONE      | Europe/London | Specify the PHP date.timezone |
| PHP_MEMORY_LIMIT  | 2G       | Specify the PHP memory limit |
| WEB_ROOT          | /var/www | Set's the web server root directory |
| WEB_PUBLIC        | -       | A suffix to the WEB_ROOT to only serve files from this location |
| SMTP_HOST         | smtp.mailtrap.io | Set SMTP hostname (uses MSMTP for sendmail) |
| SMTP_PORT         | 2525    | Set SMTP port |
| SMTP_USER         | -       | Set SMTP username |
| SMTP_FROM         | -       | Set SMTP envelope-from header |
| SMTP_PASS         | -       | Set SMTP password |
| SMTP_TLS          | On      | Enable TLS support, by default STARTTLS is enabled on port 587 |
| SMTP_CHECK_CERTS  | On      | Specifying *Off* will disable SMTP TLS certificate checks |

## FrankenPHP Configuration

This repo publishes `outeredge/edge-docker-php:8.3-frankenphp` and `:8.4-frankenphp`. These variants run [FrankenPHP](https://frankenphp.dev/) (Caddy + PHP, single process) and are intended for **Google Cloud Run** and similar serverless container platforms.

There are also `-frankenphp-super` variants that use supervisor to run FrankenPHP alongside sidecars like Valkey and Google Cloud SQL Proxy.

| Environment | Default | Description |
| --- | --- | --- |
| `CADDY_ADMIN` | `off` | Caddy admin API socket (e.g. `localhost:2019` for live inspection) |
| `CADDY_AUTO_HTTPS` | `off` | TLS strategy: `on` for ACME certs, `off` for upstream termination (Cloud Run, etc.) |
| `CADDY_GLOBAL_OPTIONS` | - | Global escape hatch for `debug` or custom `order` directives |
| `CADDY_EXTRA_CONFIG` | - | Top-level escape hatch for named snippets or additional sites |
| `CADDY_SERVER_EXTRA_DIRECTIVES` | - | Extra directives/overrides (e.g. `header`, `basicauth`, `X-Robots-Tag`) |
| `CADDY_CONF` | `default` | App-specific config from `/etc/caddy/conf.d/${CADDY_CONF}.caddy` |
| `CADDY_ENCODINGS` | `zstd br gzip` | Space-separated list of compression encodings |
| `FRANKENPHP_CONFIG` | - | Runtime tuning, e.g. `num_threads 8` or `worker /var/www/public/index.php 4` |
| `MAX_REQUEST_SIZE` | `32MB` | Maximum inbound request body size (Cloud Run limit is 32MB) |
| `PORT` | `8080` | Note, services like Cloud Run set this automatically |
| `SERVER_NAME` | `:$PORT` | The domain or port to bind to (e.g. `app.example.com`) |

To add app-level Caddy rules, drop a file at `$WEB_ROOT/Caddyfile` - it is imported automatically.

### What's different

- Single process (standard variant): FrankenPHP runs as PID 1. No supervisord, no PHP-FPM, no cron, no SSH, no Valkey sidecar, no `sudo`.
- Supervisor variant (`-frankenphp-super`): Runs `supervisord` as PID 1 with Valkey and Cloud SQL Proxy included.
- Runs as non-root user `edge` with `CAP_NET_BIND_SERVICE` removed - cannot bind privileged ports.
- Read-only-rootfs friendly.
- Debian base image.

### Additional Site Blocks

To add entirely new site blocks (e.g. for an admin domain, metrics endpoint, or monitoring), drop `.caddyfile` files into `/etc/caddy/Caddyfile.d/`. These are imported at the top level, outside of the primary site block.
