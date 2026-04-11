FROM alpine:3.23.3@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659 AS download

# renovate: datasource=github-releases depName=invoiceninja/invoiceninja
ARG IN_VERSION=5.13.14

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN set -ex; \
	wget -q -O /tmp/invoiceninja.tar \
	"https://github.com/invoiceninja/invoiceninja/releases/download/v${IN_VERSION}/invoiceninja.tar"

FROM php:8.5.5-apache@sha256:103a8cd59a029b387470deace9736a7bc5aeb167a746774c68da82bb469c578c

ARG IN_INSTALL_DIR=/usr/share/invoiceninja

RUN set -ex; \
	mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
	ln -s "/etc/apache2/conf-available/apache-limits.conf" "/etc/apache2/conf-enabled/"

# hadolint ignore=DL3008
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends supervisor mariadb-client chromium gosu; \
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

COPY --from=download --chmod=644 /tmp/invoiceninja.tar /tmp/
RUN set -ex; \
	mkdir -p $IN_INSTALL_DIR; \
	chown www-data:www-data $IN_INSTALL_DIR; \
	gosu www-data tar xvf /tmp/invoiceninja.tar -C $IN_INSTALL_DIR; \
	rm /tmp/invoiceninja.tar;

RUN set -ex; \
	rm -r /var/www/html; \
	ln -s $IN_INSTALL_DIR/public /var/www/html

RUN a2enmod rewrite

COPY --chmod=644 /rootfs/etc/supervisord.conf /etc/
COPY --chmod=755 /rootfs/usr/local/bin/docker-entrypoint.sh /usr/local/bin/
COPY --chmod=755 /rootfs/usr/local/bin/invoiceninja-version.sh /usr/local/bin/

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
