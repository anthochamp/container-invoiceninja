# hadolint ignore=DL3007
FROM alpine:latest@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c AS download

# will download the latest available version if empty/undefined
ARG IN_VERSION=

# hadolint ignore=DL3018
RUN set -ex; \
	apk add --no-cache jq

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN set -ex; \
	if [ -n "$IN_VERSION" ]; then \
	DOWNLOAD_URL="https://github.com/invoiceninja/invoiceninja/releases/download/v$IN_VERSION/invoiceninja.tar"; \
	else \
	DOWNLOAD_URL=$(wget -q -O - "https://api.github.com/repos/invoiceninja/invoiceninja/releases/latest" | jq -r '.assets[0].browser_download_url'); \
	fi; \
	wget -q -O /tmp/invoiceninja.tar "$DOWNLOAD_URL"

FROM php:8.4.6-apache@sha256:abce8fe7e3390e96d3ac52dff8e6f5ff9507f4a7bee2b18f11404b74d7efec66

ARG IN_INSTALL_DIR=/usr/share/invoiceninja

RUN set -ex; \
	mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# hadolint ignore=DL3008
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends supervisor mariadb-client chromium; \
	apt-get install -y --no-install-recommends zlib1g-dev libpng-dev libjpeg-dev libfreetype-dev; \
	apt-get install -y --no-install-recommends libgmp-dev; \
	apt-get install -y --no-install-recommends libzip-dev; \
	apt-get clean; \
	rm -rf /var/lib/apt/lists/*

RUN set -ex; \
	docker-php-ext-install bcmath; \
	docker-php-ext-install gd; \
	docker-php-ext-install gmp; \
	docker-php-ext-install mysqli; \
	docker-php-ext-install pdo_mysql; \
	docker-php-ext-install zip;

COPY --from=download --chmod=644 /tmp/invoiceninja.tar /tmp
RUN set -ex; \
	mkdir -p $IN_INSTALL_DIR; \
	chown www-data:www-data $IN_INSTALL_DIR; \
	runuser -u www-data -- tar xvf /tmp/invoiceninja.tar -C $IN_INSTALL_DIR; \
	rm /tmp/invoiceninja.tar;

RUN set -ex; \
	rm -r /var/www/html; \
	ln -s $IN_INSTALL_DIR/public /var/www/html

RUN a2enmod rewrite

COPY --chmod=644 /rootfs/etc/supervisord.conf /etc
COPY --chmod=755 /rootfs/usr/local/bin/docker-entrypoint.sh /usr/local/bin
COPY --chmod=755 /rootfs/usr/local/bin/invoiceninja-version.sh /usr/local/bin

VOLUME [ "$IN_INSTALL_DIR/storage" ]

WORKDIR $IN_INSTALL_DIR

ENV IN_INSTALL_DIR=$IN_INSTALL_DIR
ENV IS_DOCKER=true
ENV REQUIRE_HTTPS=false
ENV SNAPPDF_CHROMIUM_PATH=/usr/bin/chromium
# mitigate "production.ERROR: Writing to directory /var/www/.config/psysh is not allowed." exception
ENV XDG_CONFIG_HOME=/var/www/html/.config

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD [ "supervisord", "-c", "/etc/supervisord.conf" ]
