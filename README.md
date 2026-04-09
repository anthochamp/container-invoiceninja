# Invoice Ninja Container

![GitHub License](https://img.shields.io/github/license/anthochamp/container-invoiceninja?style=for-the-badge)
![GitHub Release](https://img.shields.io/github/v/release/anthochamp/container-invoiceninja?style=for-the-badge&color=457EC4)
![GitHub Release Date](https://img.shields.io/github/release-date/anthochamp/container-invoiceninja?style=for-the-badge&display_date=published_at&color=457EC4)

Alternative container images for [Invoice Ninja](https://invoiceninja.com/), a self-hosted invoicing, billing, and payment platform.

## How to use this image

First, generate an application key:

```shell
docker run --rm -it anthochamp/invoiceninja php artisan key:generate --show
```

Then start the container:

```shell
docker run -p 1234:80 \
  -e APP_KEY=your-generated-key \
  anthochamp/invoiceninja
```

Open a browser to <http://localhost:1234\> to access the application.

## Configuration

Sensitive values may be loaded from files by appending `__FILE` to any supported environment variable name (e.g., `IN_INITIAL_ACCOUNT_PASSWORD__FILE=/run/secrets/initial_password`).

## Application configuration

**References:**

- [config/ninja.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/ninja.php)

### Initial account

#### IN_INITIAL_ACCOUNT_EMAIL

**Default**: *empty*

#### IN_INITIAL_ACCOUNT_PASSWORD

**Default**: *empty*

## Framework configuration

### Application

**References:**

- [config/app.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/app.php)

#### APP_NAME

**Default**: `Invoice Ninja`

#### APP_DEBUG

**Default**: `false`

#### APP_URL

**Default**: `http://localhost`

#### SERVER_TIMEZONE

**Default**: `UTC`

Refer to the [PHP timezones documentation](https://www.php.net/manual/en/timezones.php) for possible values.

#### DEFAULT_LOCALE

**Default**: `en`

#### APP_KEY

**Default**: *empty*

Must be generated using the following command:

```shell
docker run --rm -it anthochamp/invoiceninja php artisan key:generate --show
```

### Broadcasting

**References:**

- [config/broadcasting.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/broadcasting.php)
- [Laravel Broadcasting documentation](https://laravel.com/docs/broadcasting)

#### BROADCAST_DRIVER

**Default**: `log`

| Driver   | Description                                              | Parameters                                                   |
|----------|----------------------------------------------------------|--------------------------------------------------------------|
| `ably`   | [Ably](https://ably.com/)                                | See [Third party > Ably](#ably)                              |
| `log`    | Should only be used for local development and debugging. |                                                              |
| `pusher` | [Pusher Channels](https://pusher.com/channels/)          | See [Third party > Pusher Channels](#pusher-channels)        |
| `redis`  | [Redis](https://redis.io/)                               | [`REDIS_BROADCAST_CONNECTION`](#redis_broadcast_connection)  |

#### REDIS_BROADCAST_CONNECTION

**Default**: `default`

Selects a [Redis configuration](#redis) for broadcasting.

### Cache

**References:**

- [config/cache.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/cache.php)
- [Laravel Cache documentation](https://laravel.com/docs/cache)

#### CACHE_DRIVER

**Default**: `file`

| Driver      | Description                                 | Parameters                                                                                                                               |
|-------------|---------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| `database`  | Uses a database table for caching.          | [`CACHE_PREFIX`](#cache_prefix), [`DB_CONNECTION`](#db_connection)                                                                       |
| `dynamodb`  | Uses AWS DynamoDB for caching.              | [`CACHE_PREFIX`](#cache_prefix), [`DYNAMODB_CACHE_TABLE`](#dynamodb_cache_table), and [Third party > Amazon DynamoDB](#amazon-dynamodb)  |
| `file`      | Uses local files in `framework/cache/data`. |                                                                                                                                          |
| `memcached` | Uses a memcached instance.                  | [`CACHE_PREFIX`](#cache_prefix), and [Third party > memcached](#memcached)                                                               |
| `redis`     | Uses a Redis instance.                      | [`CACHE_PREFIX`](#cache_prefix), [`REDIS_CACHE_CONNECTION`](#redis_cache_connection)                                                     |

#### DYNAMODB_CACHE_TABLE

**Default**: `cache`

#### REDIS_CACHE_CONNECTION

**Default**: `cache`

Selects a [Redis configuration](#redis) for caching.

#### CACHE_PREFIX

**Default**: `${APP_NAME}_cache_` (with the slug version of `APP_NAME`)

### Database

**References:**

- [config/database.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/database.php)
- [Laravel Database documentation](https://laravel.com/docs/database)

Available database connection configurations:

| Configuration | Description     | Parameters                                                                                                                                                  |
|---------------|-----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `mysql`       | MySQL / MariaDB | [`DB_HOST`](#db_host), [`DB_PORT`](#db_port), [`DB_DATABASE`](#db_database), [`DB_USERNAME`](#db_username), [`DB_PASSWORD`](#db_password)                   |
| `pgsql`       | PostgreSQL      | [`DB_HOST`](#db_host), [`DB_PORT`](#db_port), [`DB_DATABASE`](#db_database), [`DB_USERNAME`](#db_username), [`DB_PASSWORD`](#db_password)                   |
| `sqlite`      | SQLite          | [`DB_DATABASE`](#db_database)                                                                                                                               |
| `sqlsrv`      | SQL Server      | [`DB_HOST`](#db_host), [`DB_PORT`](#db_port), [`DB_DATABASE`](#db_database), [`DB_USERNAME`](#db_username), [`DB_PASSWORD`](#db_password)                   |

#### DB_CONNECTION

**Default**: `mysql`

Selects the default database configuration.

#### DB_HOST

**Default**: `127.0.0.1`

#### DB_PORT

**Default**: depends on driver — `3306` (mysql), `5432` (pgsql), `1433` (sqlsrv)

#### DB_DATABASE

**Default**: `invoiceninja` (for mysql/pgsql/sqlsrv), `database.sqlite` (for sqlite)

#### DB_USERNAME

**Default**: `invoiceninja`

#### DB_PASSWORD

**Default**: *empty*

### File Storage

**References:**

- [config/filesystems.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/filesystems.php)
- [Laravel File Storage documentation](https://laravel.com/docs/filesystem)

#### FILESYSTEM_DISK

**Default**: `public`

Available disk configurations:

| Configuration | Description            | Parameters                                                             |
|---------------|------------------------|------------------------------------------------------------------------|
| `public`      | Stores in `app/public` |                                                                        |
| `s3`          | Amazon S3              | See [Third party > Amazon S3](#amazon-s3)                              |
| `r2`          | Cloudflare R2          | See [Third party > Cloudflare R2](#cloudflare-r2)                      |
| `gcs`         | Google Cloud Storage   | See [Third party > Google Cloud Storage](#google-cloud-storage)        |

### Security

**References:**

- [config/hashing.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/hashing.php)
- [config/ninja.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/ninja.php)

#### BCRYPT_ROUNDS

**Default**: `12`

Number of bcrypt hashing rounds. This value should depend on the allocated resources for the application.

References:

- <https://php.watch/versions/8.4/password_hash-bcrypt-cost-increase\>
- <https://security.stackexchange.com/questions/3959/recommended-of-iterations-when-using-pbkdf2-sha256/3993\#3993\>

#### TRUSTED_PROXIES

**Default**: *empty*

### Logging

**References:**

- [config/logging.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/logging.php)
- [Laravel Logging documentation](https://laravel.com/docs/logging)

Available logging channel configurations:

| Configuration            | Description                                                  | Parameters                                                                                                    |
|--------------------------|--------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| `invoiceninja`           | Logs to `logs/invoiceninja.log` (7 day retention)            | [`LOG_LEVEL`](#log_level)                                                                                     |
| `invoiceninja-reminders` | Logs to `logs/invoiceninja-reminders.log` (90 day retention) | [`LOG_LEVEL`](#log_level)                                                                                     |
| `stack`                  | Multi-channel (configured for `single`)                      |                                                                                                               |
| `single`                 | Logs to `logs/laravel.log`                                   | [`LOG_LEVEL`](#log_level)                                                                                     |
| `daily`                  | Logs to `logs/laravel.log` (rotated daily, 14 day retention) | [`LOG_LEVEL`](#log_level)                                                                                     |
| `slack`                  | Logs to Slack via webhooks                                   | [`LOG_LEVEL`](#log_level), [`LOG_SLACK_WEBHOOK_URL`](#log_slack_webhook_url)                                  |
| `papertrail`             | Logs to a remote syslogd server                              | [`LOG_LEVEL`](#log_level), [`PAPERTRAIL_URL`](#papertrail_url), [`PAPERTRAIL_PORT`](#papertrail_port)         |
| `stderr`                 | Logs to the PHP stderr stream                                | [`LOG_LEVEL`](#log_level), [`LOG_STDERR_FORMATTER`](#log_stderr_formatter)                                    |
| `syslog`                 | Logs to syslog                                               | [`LOG_LEVEL`](#log_level)                                                                                     |
| `errorlog`               | Logs to the PHP errorlog stream                              | [`LOG_LEVEL`](#log_level)                                                                                     |
| `null`                   | No logs                                                      |                                                                                                               |
| `graylog`                | Logs to a Gelf server (UDP, port 12201)                      | [`GRAYLOG_SERVER`](#graylog_server)                                                                           |

#### LOG_CHANNEL

**Default**: `errorlog`

Sets the default logging channel.

#### LOG_LEVEL

**Default**: `debug` for most channels, `critical` for `slack`

Available log levels follow [RFC 5424](https://datatracker.ietf.org/doc/html/rfc5424): `emergency`, `alert`, `critical`, `error`, `warning`, `notice`, `info`, `debug`.

#### LOG_SLACK_WEBHOOK_URL

**Default**: *empty*

Relevant only for the `slack` channel. Slack Webhook URL.

#### PAPERTRAIL_URL

**Default**: *empty*

Relevant only for the `papertrail` channel. IP/hostname or path to a unix socket (set `PAPERTRAIL_PORT` to `0` in that case).

#### PAPERTRAIL_PORT

**Default**: *empty*

Relevant only for the `papertrail` channel. Port number, or `0` if `PAPERTRAIL_URL` is a unix socket.

#### LOG_STDERR_FORMATTER

**Default**: *empty*

Relevant only for the `stderr` channel. Fully qualified class name of the [Monolog formatter](https://github.com/Seldaek/monolog/blob/main/doc/02-handlers-formatters-processors.md#formatters) (e.g., `Monolog\\Formatter\\LineFormatter`).

#### GRAYLOG_SERVER

**Default**: `127.0.0.1`

Relevant only for the `graylog` channel. IP/hostname of the Gelf server (UDP, port 12201, hard-coded).

### Mail

**References:**

- [config/mail.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/mail.php)
- [Laravel Mail documentation](https://laravel.com/docs/mail)

Available mailer configurations:

| Configuration | Description                             | Parameters                                                                                                                                                                                                                                           |
|---------------|-----------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `smtp`        | SMTP server                             | [`MAIL_HOST`](#mail_host), [`MAIL_PORT`](#mail_port), [`MAIL_ENCRYPTION`](#mail_encryption), [`MAIL_USERNAME`](#mail_username), [`MAIL_PASSWORD`](#mail_password), [`MAIL_EHLO_DOMAIN`](#mail_ehlo_domain), [`MAIL_VERIFY_PEER`](#mail_verify_peer)  |
| `ses`         | Amazon SES                              | See [Third party > Amazon SES](#amazon-ses)                                                                                                                                                                                                          |
| `mailgun`     | [Mailgun](https://www.mailgun.com/)     | See [Third party > Mailgun](#mailgun)                                                                                                                                                                                                                |
| `brevo`       | [Brevo](https://www.brevo.com/)         | See [Third party > Brevo](#brevo)                                                                                                                                                                                                                    |
| `postmark`    | [Postmark](https://postmarkapp.com/)    | See [Third party > Postmark](#postmark)                                                                                                                                                                                                              |
| `log`         | Dry-send to log                         | [`MAIL_LOG_CHANNEL`](#mail_log_channel)                                                                                                                                                                                                              |
| `gmail`       | [Gmail](https://mail.google.com/)       | See [Third party > Google Mail](#google-mail)                                                                                                                                                                                                        |
| `office365`   | [Office 365](https://office.com/)       | See [Third party > Microsoft Office 365](#microsoft-office-365)                                                                                                                                                                                      |
| `failover`    | Use `smtp` by default, `log` on failure |                                                                                                                                                                                                                                                      |

#### MAIL_MAILER

**Default**: `failover`

#### MAIL_HOST

**Default**: `smtp.example.com`

Relevant only for the `smtp` configuration.

#### MAIL_PORT

**Default**: `587`

Relevant only for the `smtp` configuration.

#### MAIL_ENCRYPTION

**Default**: `tls`

Relevant only for the `smtp` configuration.

#### MAIL_USERNAME

**Default**: *empty*

Relevant only for the `smtp` configuration.

#### MAIL_PASSWORD

**Default**: *empty*

Relevant only for the `smtp` configuration.

#### MAIL_EHLO_DOMAIN

**Default**: *empty*

Relevant only for the `smtp` configuration.

#### MAIL_VERIFY_PEER

**Default**: `true`

Relevant only for the `smtp` configuration.

#### MAIL_LOG_CHANNEL

**Default**: *empty*

Relevant only for the `log` configuration.

#### MAIL_FROM_ADDRESS

**Default**: `no-reply@example.com`

#### MAIL_FROM_NAME

**Default**: value of `APP_NAME`

### Queues

**References:**

- [config/queue.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/queue.php)
- [Laravel Queues documentation](https://laravel.com/docs/queues)

Available queues configurations:

| Configuration | Description                              | Parameters                                                                                                            |
|---------------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| `sync`        | Synchronous execution (development only) |                                                                                                                       |
| `database`    | Uses the configured database             |                                                                                                                       |
| `sqs`         | Amazon SQS                               | See [Third party > Amazon SQS](#amazon-sqs)                                                                           |
| `redis`       | Redis                                    | [`REDIS_QUEUE_CONNECTION`](#redis_queue_connection), [`REDIS_QUEUE`](#redis_queue), and [Third party > Redis](#redis) |

#### QUEUE_CONNECTION

**Default**: `database`

#### REDIS_QUEUE_CONNECTION

**Default**: `default`

Selects the Redis configuration group for queues.

#### REDIS_QUEUE

**Default**: `{default}`

If using a Redis Cluster, queue names must contain a key hash tag to ensure all Redis keys land in the same hash slot.

### Session

**References:**

- [config/session.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/session.php)
- [Laravel Session documentation](https://laravel.com/docs/session)

#### SESSION_DRIVER

**Default**: `file`

Available session drivers:

| Driver       | Description                        |
|--------------|------------------------------------|
| `file`       | Stored in `framework/sessions`     |
| `cookie`     | Stored in encrypted cookies        |
| `database`   | Stored in a database table         |
| `memcached`  | Memcached                          |
| `redis`      | Redis                              |
| `dynamodb`   | Amazon DynamoDB                    |
| `array`      | Stored in memory (testing only)    |

#### SESSION_LIFETIME

**Default**: `120`

Number of minutes the session may remain idle before expiring.

#### SESSION_CONNECTION

**Default**: *empty*

Relevant only for the `database` and `redis` drivers.

#### SESSION_STORE

**Default**: *empty*

Relevant only for the `dynamodb`, `memcached`, and `redis` drivers. Cache store to use.

#### SESSION_COOKIE

**Default**: `$APP_NAME_session` (APP_NAME slugged)

#### SESSION_DOMAIN

**Default**: *empty*

Domain the cookie is available to.

#### SESSION_SECURE_COOKIE

**Default**: `false`

When `true`, session cookies are only sent over HTTPS connections.

#### SESSION_SAME_SITE

**Default**: `lax`

Either `lax`, `strict`, `none`, or empty. Controls cross-site cookie behavior.

## Third-party integrations

### Ably

**References:**

- [config/broadcasting.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/broadcasting.php)

#### ABLY_KEY

**Default**: *empty*

### Amazon (common)

**References:**

- [config/cache.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/cache.php)
- [config/filesystems.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/filesystems.php)
- [config/queue.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/queue.php)
- [config/services.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/services.php)

#### AWS_ACCESS_KEY_ID

**Default**: *empty*

#### AWS_SECRET_ACCESS_KEY

**Default**: *empty*

#### AWS_DEFAULT_REGION

**Default**: `us-east-1`

### Amazon DynamoDB

**References:**

- [config/cache.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/cache.php)

#### DYNAMODB_ENDPOINT

**Default**: *empty*

### Amazon S3

**References:**

- [config/filesystems.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/filesystems.php)

#### AWS_BUCKET

**Default**: *empty*

#### AWS_URL

**Default**: *empty*

Public URL of the S3 bucket.

#### AWS_ENDPOINT

**Default**: *empty*

#### AWS_USE_PATH_STYLE_ENDPOINT

**Default**: `false`

### Amazon SES

**References:**

- [config/services.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/services.php)

#### SES_REGION

**Default**: `us-east-1`

### Amazon SQS

**References:**

- [config/queue.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/queue.php)

#### SQS_PREFIX

**Default**: `https://sqs.us-east-1.amazonaws.com/your-account-id`

#### SQS_SUFFIX

**Default**: *empty*

#### SQS_QUEUE

**Default**: `default`

### Brevo

**References:**

- [config/services.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/services.php)

#### BREVO_SECRET

**Default**: *empty*

### Cloudflare R2

**References:**

- [config/filesystems.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/filesystems.php)

#### R2_ACCESS_KEY_ID

**Default**: *empty*

#### R2_SECRET_ACCESS_KEY

**Default**: *empty*

#### R2_DEFAULT_REGION

**Default**: *empty*

#### R2_BUCKET

**Default**: *empty*

#### R2_URL

**Default**: *empty*

#### R2_ENDPOINT

**Default**: *empty*

#### R2_USE_PATH_STYLE_ENDPOINT

**Default**: `false`

### GoCardless (ex-Nordigen)

**References:**

- [config/ninja.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/ninja.php)

#### NORDIGEN_SECRET_ID

**Default**: *empty*

#### NORDIGEN_SECRET_KEY

**Default**: *empty*

#### NORDIGEN_TEST_MODE

**Default**: `false`

### Google Cloud (common)

**References:**

- [config/filesystems.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/filesystems.php)

#### GOOGLE_CLOUD_PROJECT_ID

**Default**: *empty*

#### GOOGLE_CLOUD_KEY_FILE

**Default**: *empty*

### Google Cloud Storage

**References:**

- [config/filesystems.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/filesystems.php)

#### GOOGLE_CLOUD_STORAGE_BUCKET

**Default**: *empty*

#### GOOGLE_CLOUD_STORAGE_PATH_PREFIX

**Default**: *empty*

#### GOOGLE_CLOUD_STORAGE_STORAGE_API_URI

**Default**: *empty*

### Google Mail

**References:**

- [config/ninja.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/ninja.php)

#### GOOGLE_CLIENT_ID

**Default**: *empty*

#### GOOGLE_CLIENT_SECRET

**Default**: *empty*

### Mailgun

**References:**

- [config/services.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/services.php)

#### MAILGUN_DOMAIN

**Default**: *empty*

#### MAILGUN_SECRET

**Default**: *empty*

#### MAILGUN_ENDPOINT

**Default**: `api.mailgun.net`

#### MAILGUN_WEBHOOK_SIGNING_KEY

**Default**: *empty*

#### MAILGUN_FROM_ADDRESS

**Default**: *empty*

Takes precedence over [`MAIL_FROM_ADDRESS`](#mail_from_address) if defined.

#### MAILGUN_FROM_NAME

**Default**: *empty*

Takes precedence over [`MAIL_FROM_NAME`](#mail_from_name) if defined.

### Microsoft Office 365

**References:**

- [config/ninja.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/ninja.php)

#### MICROSOFT_CLIENT_SECRET

**Default**: *empty*

#### MICROSOFT_CLIENT_ID

**Default**: *empty*

#### MICROSOFT_TENANT_ID

**Default**: *empty*

### memcached

**References:**

- [config/cache.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/cache.php)

#### MEMCACHED_PERSISTENT_ID

**Default**: *empty*

#### MEMCACHED_USERNAME

**Default**: *empty*

#### MEMCACHED_PASSWORD

**Default**: *empty*

#### MEMCACHED_HOST

**Default**: `127.0.0.1`

#### MEMCACHED_PORT

**Default**: `11211`

### Postmark

**References:**

- [config/postmark.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/postmark.php)
- [config/services.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/services.php)

#### POSTMARK_SECRET

**Default**: *empty*

### Pusher Channels

**References:**

- [config/broadcasting.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/broadcasting.php)

#### PUSHER_APP_KEY

**Default**: *empty*

#### PUSHER_APP_SECRET

**Default**: *empty*

#### PUSHER_APP_ID

**Default**: *empty*

#### PUSHER_APP_CLUSTER

**Default**: `mt1`

#### PUSHER_SCHEME

**Default**: `https`

#### PUSHER_HOST

**Default**: `api-${PUSHER_APP_CLUSTER}.pusher.com`

#### PUSHER_PORT

**Default**: `443`

### Redis

**References:**

- [config/database.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/database.php)
- [Laravel Redis documentation](https://laravel.com/docs/redis)

Available Redis configurations: `default`, `cache`.

#### REDIS_HOST

**Default**: `localhost`

#### REDIS_PASSWORD

**Default**: *empty*

#### REDIS_PORT

**Default**: `6379`

#### REDIS_DB

**Default**: `0`

Relevant only for the `default` configuration.

#### REDIS_CACHE_DB

**Default**: `1`

Relevant only for the `cache` configuration.

## Maintenance mode

Refer to the [Laravel maintenance mode documentation](https://laravel.com/docs/configuration#maintenance-mode).

## References

- [Invoice Ninja documentation](https://invoiceninja.com/docs/)
- [Invoice Ninja on GitHub](https://github.com/invoiceninja/invoiceninja)
- [Official Invoice Ninja Docker Hub image](https://hub.docker.com/r/invoiceninja/invoiceninja/)
