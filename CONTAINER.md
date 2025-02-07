# Self-hosted Invoice Ninja container images

Alternative to the [official container images](https://hub.docker.com/r/invoiceninja/invoiceninja/).

Sources are available on [GitHub](https://github.com/anthochamp/container-invoiceninja).

<!-- TOC tocDepth:2..3 chapterDepth:2..6 -->

- [Image tags](#image-tags)
- [How to use this image](#how-to-use-this-image)
- [Application configuration](#application-configuration)
  - [Initial account](#initial-account)
  - [Ninja](#ninja)
- [Framework configuration](#framework-configuration)
  - [Application](#application)
  - [Broadcasting](#broadcasting)
  - [Cache](#cache)
  - [Database](#database)
  - [File Storage](#file-storage)
  - [Security](#security)
  - [Logging](#logging)
  - [Mail](#mail)
  - [Queues](#queues)
  - [Session](#session)
- [Third-party integrations](#third-party-integrations)
  - [Ably](#ably)
  - [Amazon (common)](#amazon-common)
  - [Amazon DynamoDB](#amazon-dynamodb)
  - [Amazon S3](#amazon-s3)
  - [Amazon SES](#amazon-ses)
  - [Amazon SQS](#amazon-sqs)
  - [Brevo](#brevo)
  - [Cloudflare R2](#cloudflare-r2)
  - [GoCardless (ex-Nordigen)](#gocardless-ex-nordigen)
  - [Google Cloud (common)](#google-cloud-common)
  - [Google Cloud Storage](#google-cloud-storage)
  - [Google Mail](#google-mail)
  - [Mailgun](#mailgun)
  - [Microsoft Office 365](#microsoft-office-365)
  - [memcached](#memcached)
  - [Postmark](#postmark)
  - [Pusher Channels](#pusher-channels)
  - [Redis](#redis)
- [Maintenance mode](#maintenance-mode)

<!-- /TOC -->

## Image tags

- `x.y.z-invoiceninjaA.B.C` tags the `x.y.z` container image version, embedded with
the Invoice Ninja `A.B.C` version.
- `edge-invoiceninjaA.B.C` tags the container image built from the last repository
commit, embedded with the Invoice Ninja `A.B.C` version.

Tags aliases :

- `x.y-invoiceninjaA.B.C` aliases the latest patch version of the container image `x.y`
major+minor version, embedded with the Invoice Ninja `A.B.C` version;
- `x-invoiceninjaA.B.C` aliases the latest minor+patch version of the container image
`x` major version, embedded with the Invoice Ninja `A.B.C` version;
- `x.y.z` aliases the `x.y.z` container image version embedded with the latest
Invoice Ninja version (Note: only the latest container image version gets updated);
- `x.y` aliases the latest patch version of the container image `x.y` major+minor
version, embedded with the latest Invoice Ninja release (Note: only the latest container
image major+minor version gets updated);
- `x` aliases the latest minor+patch version of the container image `x` major
version, embedded with the latest Invoice Ninja version (Note: only the latest container
image major version gets updated);
- `invoiceninjaA.B` aliases the latest container image version, embedded with the latest
patch version of the Invoice Ninja `A.B` major+minor version;
- `invoiceninjaA` aliases the latest container image version, embedded with the latest
minor+patch version of the Invoice Ninja `A` major version;
- `latest` aliases the latest `x.y.z-invoiceninjaA.B.C` tag;
- `edge-invoiceninjaA.B` aliases the container image built from the last repository
commit, embedded with the latest patch version of the Invoice Ninja `A.B` major+minor
version;
- `edge-invoiceninjaA` aliases the container image built from the last repository
commit, embedded with the latest minor+patch version of the Invoice Ninja `A` major
version.
- `edge` aliases the latest `edge-invoiceninjaA.B.C` tag;

## How to use this image

First, you'll need to generate an application key :

```shell
docker run --rm -it anthochamp/invoiceninja php artisan key:generate --show
```

Then, execute the following command :

```shell
docker run -p 1234:80 anthochamp/invoiceninja
```

And test it by opening a browser to <http://localhost:1234>.

## Application configuration

As an alternative to passing sensitive information via environment variables, `__FILE` may be appended to any of the listed environment variables below, causing the initialization script to load the values for those variables from files present in the container.

In particular, this can be used to load values from Docker secrets stored in `/run/secrets/<secret_name>` files. For example : `IN_INITIAL_ACCOUNT_PASSWORD__FILE=/run/secrets/initial_password`.

### Initial account

#### IN_INITIAL_ACCOUNT_EMAIL

**Default**: *empty*

#### IN_INITIAL_ACCOUNT_PASSWORD

**Default**: *empty*

### Ninja

**References**:

- [config/ninja.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/ninja.php)

## Framework configuration

As an alternative to passing sensitive information via environment variables, `__FILE` may be appended to any of the listed environment variables below, causing the initialization script to load the values for those variables from files present in the container.

In particular, this can be used to load values from Docker secrets stored in `/run/secrets/<secret_name>` files. For example : `MAIL_PASSWORD=/run/secrets/mail_password`.

### Application

**References**:

- [config/app.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/app.php)

#### APP_NAME

**Default**: `Invoice Ninja`

#### APP_DEBUG

**Default**: `false`

#### APP_URL

**Default**: `http://localhost`

#### SERVER_TIMEZONE

**Default**: `UTC`

Refer to [PHP documentation](https://www.php.net/manual/en/timezones.php) for possible values.

#### DEFAULT_LOCALE

**Default**: `en`

#### APP_KEY

**Default**: *empty*

Must be generated using the following command :

```shell
docker run --rm -it anthochamp/invoiceninja php artisan key:generate --show
```

### Broadcasting

**References**:

- [config/broadcasting.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/broadcasting.php)
- [Laravel Broacasting documentation](https://laravel.com/docs/broadcasting)

#### BROADCAST_DRIVER

**Default**: `log`

| Driver | Description | Parameters |
| - | - | - |
| `ably` | [Ably](https://ably.com/) | See [Third party > Ably](#ably) |
| `log` | Should only be used for local development and debugging. | |
| `pusher` | [Pusher Channels](https://pusher.com/channels/) | see [Third party > Pusher Channels](#pusher-channels) |
| `redis` | [Redis](https://redis.io/) | [`REDIS_BROADCAST_CONNECTION`](#redis_broadcast_connection) |

#### REDIS_BROADCAST_CONNECTION

**Default**: `default`

Selects a [Redis configuration](#redis) for broadcasting.

### Cache

- [config/cache.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/cache.php)
- [Laravel Cache documentation](https://laravel.com/docs/cache)

#### CACHE_DRIVER

**Default**: `file`

| Driver | Description | Parameters |
| - | - | - |
| `database` | Uses a database table for caching. The default database connection configuration specified in [`DB_CONNECTION`](#db_connection) will be used. | [`CACHE_PREFIX`](#cache_prefix), [`DB_CONNECTION`](#db_connection) |
| `dynamodb` | Uses a AWS DynamoDB table for caching. | [`CACHE_PREFIX`](#cache_prefix), [`DYNAMODB_CACHE_TABLE`](#dynamodb_cache_table), and [Third party > Amazon DynamoDB](#amazon-dynamodb) |
| `file` | Uses local files stored in `framework/cache/data` for caching. | |
| `memcached` | Uses a memcached instance for caching. | [`CACHE_PREFIX`](#cache_prefix), and [Third party > memcached](#memcached) |
| `redis` | Uses a Redis instance for caching. | [`CACHE_PREFIX`](#cache_prefix), [`REDIS_CACHE_CONNECTION`](#redis_cache_connection) |

#### DYNAMODB_CACHE_TABLE

**Default**: `cache`

#### REDIS_CACHE_CONNECTION

**Default**: `cache`

Selects a [Redis configuration](#redis) for caching.

#### CACHE_PREFIX

**Default**: `${APP_NAME}_cache_` (with the slug version of `APP_NAME`)

### Database

**References**:

- [config/database.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/database.php)
- [Laravel Database documentation](https://laravel.com/docs/database)

Available database connection configurations:

| Configuration | Description | Parameters |
| - | - | - |
| `mysql` | MySQL / MariaDB database connection | [`DB_HOST`](#db_host), [`DB_PORT`](#db_port), [`DB_DATABASE`](#db_database), [`DB_USERNAME`](#db_username), [`DB_PASSWORD`](#db_password) |
| `pgsql`| Postgres database connection | [`DB_HOST`](#db_host), [`DB_PORT`](#db_port), [`DB_DATABASE`](#db_database), [`DB_USERNAME`](#db_username), [`DB_PASSWORD`](#db_password) |
| `sqlite` | SQLite database connection | [`DB_DATABASE`](#db_database) |
| `sqlsrv`| SQL Server database connection | [`DB_HOST`](#db_host), [`DB_PORT`](#db_port), [`DB_DATABASE`](#db_database), [`DB_USERNAME`](#db_username), [`DB_PASSWORD`](#db_password) |

#### DB_CONNECTION

**Default**: `mysql`

Selects the default database configuration.

#### DB_HOST

**Default**: `127.0.0.1`

#### DB_PORT

**Default**:

| Configuration | Default value |
| - | - |
| `mysql` | `3306` |  
| `pgsql`| `5432` |
| `sqlsrv`| `1433` |

#### DB_DATABASE

**Default**:

| Configuration | Default value |
| - | - |
| `mysql`, `pgsql` and `sqlsrv` | `invoiceninja` |  
| `sqlite`| `database.sqlite` |

#### DB_USERNAME

**Default**: `invoiceninja`

#### DB_PASSWORD

**Default**: *empty*

### File Storage

**References**:

- [config/filesystems.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/filesystems.php)
- [Laravel File Storage documentation](https://laravel.com/docs/filesystem)

#### FILESYSTEM_DISK

**Default**: `public`

Available disk configurations:

| Configuration | Description | Parameters |
| - | - | - |
| `public` | Stores in `app/public` directory | |
| `s3` | Amazon S3 | See [Third party > Amazon S3](#amazon-s3) |
| `r2` | Cloudflare R2 | [Third party > Cloudflare R2](#cloudflare-r2) |
| `gcs` | Google Cloud Storage | [Third party > Google Cloud Storage](#google-cloud-storage) |

### Security

**References**:

- [config/hashing.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/hashing.php)
- [config/ninja.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/ninja.php)

#### BCRYPT_ROUNDS

**Default**: `12`

This value should depend on the allocated resource for the application.

References:

- <https://php.watch/versions/8.4/password_hash-bcrypt-cost-increase>
- A detailed explanation for a generic case : <https://security.stackexchange.com/questions/3959/recommended-of-iterations-when-using-pbkdf2-sha256/3993#3993>

#### TRUSTED_PROXIES

**Default**: *empty*

### Logging

**References**:

- [config/logging.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/logging.php)
- [Laravel Logging documentation](https://laravel.com/docs/logging)

Available logging channel configurations :

| Configuration | Description | Parameters |
| - | - | - |
| `invoiceninja` | Logs records into `logs/invoiceninja.log` with a 7 days retention policy | [`LOG_LEVEL`](#log_level) |
| `invoiceninja-reminders` | Logs records into `logs/invoiceninja-reminders.log` with a 90 days retention policy |[`LOG_LEVEL`](#log_level) |
| `stack` | Multi-channel (configured for `single`) | |
| `single` | Logs records into `logs/laravel.log` |[`LOG_LEVEL`](#log_level) |
| `daily` | Logs records into `logs/laravel.log` (rotated daily) with a 14 days retention policy |[`LOG_LEVEL`](#log_level) |
| `slack` | Logs records to a Slack account using Slack Webhooks. The Bot name is `Laravel Log`. | [`LOG_LEVEL`](#log_level), [`LOG_SLACK_WEBHOOK_URL`](#log_slack_webhook_url) |
| `papertrail` | Logs records to a remote Syslogd server. | [`LOG_LEVEL`](#log_level), [`PAPERTRAIL_URL`](#papertrail_url), [`PAPERTRAIL_PORTL`](#papertrail_port) |
| `stderr` | Logs records into the stderr PHP stream with an optional formatter. | [`LOG_LEVEL`](#log_level), [`LOG_STDERR_FORMATTER`](#log_stderr_formatter) |
| `syslog` | Logs records to the syslog. | [`LOG_LEVEL`](#log_level) |
| `errorlog` | Logs records into the stderr PHP stream. | [`LOG_LEVEL`](#log_level) |
| `null` | No logs | |
| `graylog` | Logs records to a Gelf server. | [`GRAYLOG_SERVER`](#graylog_server) |

#### LOG_CHANNEL

**Default**: `errorlog`

Sets the default logging channel configuration.

#### LOG_LEVEL

**Default**:

| Configuration | Default value |
| - | - |
| `invoiceninja` | `debug` |
| `invoiceninja-reminders` | `debug` |
| `stack` | - |
| `single` | `debug` |
| `daily` | `debug` |
| `slack` | `critical` |
| `papertrail` | `debug` |
| `stderr` | `debug` |
| `syslog` | `debug` |
| `errorlog` | `debug` |
| `null` | - |
| `graylog` | `debug` (hard-coded) |

Available log levels follows [RFC 5424 specification](https://datatracker.ietf.org/doc/html/rfc5424) : `emergency`, `alert`, `critical`, `error`, `warning`, `notice`, `info` and `debug`.

#### LOG_SLACK_WEBHOOK_URL

**Default**: *empty*

Relevant only for the `slack` configuration.

Slack Webhook URL.

#### PAPERTRAIL_URL

**Default**: *empty*

Relevant only for the `papertrail` configuration.

Either IP/hostname or a path to a unix socket (`PAPERTRAIL_PORT` must be `0` then).

#### PAPERTRAIL_PORT

**Default**: *empty*

Relevant only for the `papertrail` configuration.

Port number, or 0 if `PAPERTRAIL_URL` is a unix socket.

#### LOG_STDERR_FORMATTER

**Default**: *empty*

Relevant only for the `stderr` configuration.

The fully qualified name of the [monolog formatter](https://github.com/Seldaek/monolog/blob/main/doc/02-handlers-formatters-processors.md#formatters) class (eg. `Monolog\Formatter\LineFormatter`). Be aware of the `\` character in shell, it is used for escaping. The actual environment value should be `Monolog\\Formatter\\LineFormatter`.

#### GRAYLOG_SERVER

**Default**: `127.0.0.1`

Relevant only for the `graylog` configuration.

IP/hostname of the Gelf server. Other transport parameters are hard-coded : UDP on remote port 12201.

### Mail

**References**:

- [config/mail.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/mail.php)
- [Laravel Mail documentation](https://laravel.com/docs/mail)

Available mailer configurations :

| Configuration | Description | Parameters |
| - | - | - |
| `smtp` | SMTP server | [`MAIL_HOST`](#mail_host), [`MAIL_PORT`](#mail_port), [`MAIL_ENCRYPTION`](#mail_encryption), [`MAIL_USERNAME`](#mail_username), [`MAIL_PASSWORD`](#mail_password), [`MAIL_EHLO_DOMAIN`](#mail_ehlo_domain), [`MAIL_VERIFY_PEER`](#mail_verify_peer) |
| `ses` | Amazon SES | See [Third party > Amazon SES](#amazon-ses) |
| `mailgun` | [Mailgun](https://www.mailgun.com/) | See [Third party > Mailgun](#mailgun) |
| `brevo` | [Brevo](https://www.brevo.com/) | See [Third party > Brevo](#brevo) |
| `postmark` | [Postmark](https://postmarkapp.com/) | See [Third party > Postmark](#postmark) |
| `log` | Dry-send to log | [`MAIL_LOG_CHANNEL`](#mail_log_channel) |
| `gmail` | [GMail](https://mail.google.com/) | See [Third party > Google Mail](#google-mail) |
| `office365` | [Office 365](https://office.com/) | See [Third party > Microsoft Office 365](#microsoft-office-365) |
| `failover` | Use `smtp` configuration by default or `log` on `smtp` failure | |

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

**References**:

- [config/queue.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/queue.php)
- [Laravel Queues documentation](https://laravel.com/docs/queues)

Available queues configurations :

| Configuration | Description | Parameters |
| - | - | - |
| `sync` | Synchronous execution in the foreground (should only be used for development) | |
| `database` | Use the configured [Database](#database) | |
| `sqs` | Amazon SQS | See [Third party > Amazon SQS](#amazon-sqs) |
| `redis` | Redis | [`REDIS_QUEUE_CONNECTION`](#redis_queue_connection), [`REDIS_QUEUE`](#redis_queue), and [Third party > Redis](#redis) |

#### QUEUE_CONNECTION

**Default**: `database`

#### REDIS_QUEUE_CONNECTION

**Default**: `default`

Selects the redis configuration group for queues (see [Redis](#redis)).

#### REDIS_QUEUE

**Default**: `{default}`

If your Redis queue connection uses a Redis Cluster, your queue names must contain a key hash tag. This is required in order to ensure all of the Redis keys for a given queue are placed into the same hash slot.

### Session

**References**:

- [config/session.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/session.php)
- [Laravel Session documentation](https://laravel.com/docs/session)

#### SESSION_DRIVER

**Default**: `file`

Available session drivers:

| Driver | Description | Parameters |
| - | - | - |
| `file` | Stored in `framework/sessions` directory | [`SESSION_LIFETIME`](#session_lifetime), [`SESSION_COOKIE`](#session_cookie), [`SESSION_DOMAIN`](#session_domain), [`SESSION_SECURE_COOKIE`](#session_secure_cookie), [`SESSION_SAME_SITE`](#session_same_site) |
| `cookie`| Stored in secure, encrypted cookies | [`SESSION_LIFETIME`](#session_lifetime), [`SESSION_COOKIE`](#session_cookie), [`SESSION_DOMAIN`](#session_domain), [`SESSION_SECURE_COOKIE`](#session_secure_cookie), [`SESSION_SAME_SITE`](#session_same_site) |
| `database`| stored in a relational database. | [`SESSION_LIFETIME`](#session_lifetime), [`SESSION_COOKIE`](#session_cookie), [`SESSION_DOMAIN`](#session_domain), [`SESSION_SECURE_COOKIE`](#session_secure_cookie), [`SESSION_SAME_SITE`](#session_same_site), [`SESSION_CONNECTION`](#session_connection) |
| `memcached` | Memcached | [`SESSION_LIFETIME`](#session_lifetime), [`SESSION_COOKIE`](#session_cookie), [`SESSION_DOMAIN`](#session_domain), [`SESSION_SECURE_COOKIE`](#session_secure_cookie), [`SESSION_SAME_SITE`](#session_same_site), [`SESSION_STORE`](#session_store), and [Third party > Memcached](#memcached) |
| `redis` | Redis | [`SESSION_LIFETIME`](#session_lifetime), [`SESSION_COOKIE`](#session_cookie), [`SESSION_DOMAIN`](#session_domain), [`SESSION_SECURE_COOKIE`](#session_secure_cookie), [`SESSION_SAME_SITE`](#session_same_site), [`SESSION_STORE`](#session_store),[`SESSION_CONNECTION`](#session_connection), and [Third party > Redis](#redis) |
| `dynamodb` | Amazon DynamoDB | [`SESSION_LIFETIME`](#session_lifetime), [`SESSION_COOKIE`](#session_cookie), [`SESSION_DOMAIN`](#session_domain), [`SESSION_SECURE_COOKIE`](#session_secure_cookie), [`SESSION_SAME_SITE`](#session_same_site), [`SESSION_STORE`](#session_store), and [Third party > Amazon DynamoDB](#amazon-dynamodb) |
| `array`| Stored in memory | [`SESSION_LIFETIME`](#session_lifetime), [`SESSION_COOKIE`](#session_cookie), [`SESSION_DOMAIN`](#session_domain), [`SESSION_SECURE_COOKIE`](#session_secure_cookie), [`SESSION_SAME_SITE`](#session_same_site) |

#### SESSION_LIFETIME

**Default**: `120`

Specify the number of minutes that you wish the session to be allowed to remain idle before it expires.

#### SESSION_CONNECTION

**Default**: *empty*

Relevant only for the `database` and `redis` drivers.

#### SESSION_STORE

**Default**: *empty*

Relevant only for the `dynamodb`, `memcached` and `redis` drivers.

Cache store that should be used for these drivers.

#### SESSION_COOKIE

**Default**: `$APP_NAME`_session (APP_NAME is slugged)

#### SESSION_DOMAIN

**Default**: *empty*

Determine which domains the cookie is available to.

#### SESSION_SECURE_COOKIE

**Default**: `false`

If this option is `true`, session cookies will only be sent back to the server if the browser has a HTTPS connection. This will keep the cookie from being sent to you when it can't be done securely.

#### SESSION_SAME_SITE

**Default**: `lax`

Either `lax`, `strict`, `none` or empty.

Determines how your cookies behave when cross-site requests take place, and can be used to mitigate CSRF attacks.

## Third-party integrations

### Ably

**References**:

- [config/broadcasting.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/broadcasting.php)

#### ABLY_KEY

**Default**: *empty*

### Amazon (common)

**References**:

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

**References**:

- [config/cache.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/cache.php)

#### DYNAMODB_ENDPOINT

**Default**: *empty*

### Amazon S3

**References**:

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

**References**:

- [config/services.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/services.php)

#### SES_REGION

**Default**: `us-east-1`

### Amazon SQS

**References**:

- [config/queue.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/queue.php)

#### SQS_PREFIX

**Default**: `https://sqs.us-east-1.amazonaws.com/your-account-id`

#### SQS_SUFFIX

**Default**: *empty*

#### SQS_QUEUE

**Default**: `default`

### Brevo

**References**:

- [config/services.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/services.php)

#### BREVO_SECRET

**Default**: *empty*

### Cloudflare R2

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

**References**:

- [config/ninja.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/ninja.php)

#### NORDIGEN_SECRET_ID

**Default**: *empty*

#### NORDIGEN_SECRET_KEY

**Default**: *empty*

#### NORDIGEN_TEST_MODE

**Default**: `false`

### Google Cloud (common)

- [config/filesystems.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/filesystems.php)

#### GOOGLE_CLOUD_PROJECT_ID

**Default**: *empty*

#### GOOGLE_CLOUD_KEY_FILE

**Default**: *empty*

### Google Cloud Storage

- [config/filesystems.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/filesystems.php)

#### GOOGLE_CLOUD_STORAGE_BUCKET

**Default**: *empty*

#### GOOGLE_CLOUD_STORAGE_PATH_PREFIX

**Default**: *empty*

#### GOOGLE_CLOUD_STORAGE_STORAGE_API_URI

**Default**: *empty*

### Google Mail

**References**:

- [config/ninja.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/ninja.php)

#### GOOGLE_CLIENT_ID

**Default**: *empty*

#### GOOGLE_CLIENT_SECRET

**Default**: *empty*

### Mailgun

**References**:

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

**References**:

- [config/ninja.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/ninja.php)

#### MICROSOFT_CLIENT_SECRET

**Default**: *empty*

#### MICROSOFT_CLIENT_ID

**Default**: *empty*

#### MICROSOFT_TENANT_ID

**Default**: *empty*

### memcached

**References**:

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

**References**:

- [config/postmark.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/postmark.php)
- [config/services.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/services.php)

#### POSTMARK_SECRET

**Default**: *empty*

### Pusher Channels

**References**:

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

**References**:

- [config/database.php](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/config/database.php)
- [Laravel Redis documentation](https://laravel.com/docs/redis)

Available database connection configurations:

| Configuration |
| - |
| `default` |
| `cache` |

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

Refer to <https://laravel.com/docs/configuration#maintenance-mode>
