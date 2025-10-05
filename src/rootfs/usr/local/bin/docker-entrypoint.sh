#!/bin/sh
set -eu

# Ensure mounted volume permissions
chown -R www-data:www-data "$IN_INSTALL_DIR/storage"

# shellcheck disable=SC2120,SC3043
replaceEnvSecrets() {
	# replaceEnvSecrets 1.0.0
	# https://gist.github.com/anthochamp/d4d9537f52e5b6c42f0866dd823a605f
	local prefix="${1:-}"

	for envSecretName in $(export | awk '{print $2}' | grep -oE '^[^=]+' | grep '__FILE$'); do
		if [ -z "$prefix" ] || printf '%s' "$envSecretName" | grep "^$prefix" >/dev/null; then
			local envName
			envName=$(printf '%s' "$envSecretName" | sed 's/__FILE$//')

			local filePath
			filePath=$(eval echo '${'"$envSecretName"':-}')

			if [ -n "$filePath" ]; then
				if [ -f "$filePath" ]; then
					echo Using content from "$filePath" file for "$envName" environment variable value.

					export "$envName"="$(cat -A "$filePath")"
					unset "$envSecretName"
				else
					echo ERROR: Environment variable "$envSecretName" is defined but does not point to a regular file. 1>&2
					exit 1
				fi
			fi
		fi
	done
}

replaceEnvSecrets

# default is "production" in config/app.php but "selfhosted" in config/ninja.php, lets force it anyway
export APP_ENV="${APP_ENV:-production}"
# default is the same (config/app.php) but we need it here, so lets define it now if it isn't already
export APP_NAME="${APP_NAME:-"Invoice Ninja"}"

# default is "forge" (config/database.php) for both
export DB_DATABASE="${DB_DATABASE:-invoiceninja}"
export DB_USERNAME="${DB_USERNAME:-invoiceninja}"

# default is "10" (config/hashing.php), which is arguably not enough (see references in CONTAINER.md)
export BCRYPT_ROUNDS="${BCRYPT_ROUNDS:-12}"

# default is us-east-1 for SQS (config/cache.php) and SQS (config/queue.php) but empty for S3 (config/filesystems.php), better to normalize
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-"us-east-1"}"
# default is "your-project-id" (config/filesystems.php)
export GOOGLE_CLOUD_PROJECT_ID="${GOOGLE_CLOUD_PROJECT_ID:-""}"
# default is "your-bucket" (config/filesystems.php)
export GOOGLE_CLOUD_STORAGE_BUCKET="${GOOGLE_CLOUD_STORAGE_BUCKET:-""}"

# default is "stack" (= single) (config/logging.php), but it's not adapted for docker
export LOG_CHANNEL="${LOG_CHANNEL:-errorlog}"

# default is "smtp" (config/mail.php), but failover is the same with an additional logging in case of failure
export MAIL_MAILER="${MAIL_MAILER:-failover}"
# default is "smtp.mailgun.org" (config/mail.php), which complicates understanding
export MAIL_HOST="${MAIL_HOST:-"smtp.example.com"}"
# default is "hello@example.com" (config/mail.php)
export MAIL_FROM_ADDRESS="${MAIL_FROM_ADDRESS:-"no-reply@example.com"}"
# default is "Example" (config/mail.php), which would require the var to be set
export MAIL_FROM_NAME="${MAIL_FROM_NAME:-$APP_NAME}"

# default is "sync" (config/queue.php), which is for development only
export QUEUE_CONNECTION="${QUEUE_CONNECTION:-database}"
# default is "default" (config/queue.php), which defeat the purpose
export REDIS_QUEUE="${REDIS_QUEUE:-"{default}"}"

export PHP_MEMORY_LIMIT="${PHP_MEMORY_LIMIT:-512M}" # already defined by php image
export PHP_UPLOAD_LIMIT="${PHP_UPLOAD_LIMIT:-512M}" # already defined by php image
export PHP_MAX_TIME="${PHP_MAX_TIME:-1800}"
export APACHE_BODY_LIMIT="${APACHE_BODY_LIMIT:-536870912}"

cat <<EOF >"$PHP_INI_DIR/conf.d/invoiceninja.ini"
memory_limit=$PHP_MEMORY_LIMIT
upload_max_filesize=$PHP_UPLOAD_LIMIT
post_max_size=$PHP_UPLOAD_LIMIT
max_execution_time=$PHP_MAX_TIME
max_input_time=$PHP_MAX_TIME
EOF

cat <<EOF >"/etc/apache2/conf-available/apache-limits.conf"
LimitRequestBody $APACHE_BODY_LIMIT
EOF

if [ "$1" != "supervisord" ]; then
	exec "$@"
fi

if [ -z "${SESSION_SECURE_COOKIE:-}" ]; then
	echo "You did not defined the SESSION_SECURE_COOKIE environment variable. The default is false but if you access Invoice Ninja only through a secure HTTPS connection, you can set it to true to increase security."
	export SESSION_SECURE_COOKIE="false"
fi

runuser -u www-data -- php artisan optimize

# required for filesystems.links to be created (symlink of public/storage to storage/app/public)
runuser -u www-data -- php artisan storage:link

runuser -u www-data -- php artisan migrate --isolated --force

uninitialized=$(runuser -u www-data -- php artisan tinker --execute='echo Schema::hasTable("accounts") && !App\Models\Account::all()->first();')
if [ "$uninitialized" = "1" ]; then
	runuser -u www-data php artisan db:seed

	if [ -n "${IN_INITIAL_ACCOUNT_EMAIL:-}" ] && [ -n "${IN_INITIAL_ACCOUNT_PASSWORD:-}" ]; then
		runuser -u www-data -- php artisan ninja:create-account --email "$IN_INITIAL_ACCOUNT_EMAIL" --password "$IN_INITIAL_ACCOUNT_PASSWORD"
	fi

	runuser -u www-data -- php artisan ninja:react
fi

exec docker-php-entrypoint "$@"
