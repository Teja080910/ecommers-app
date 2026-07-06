FROM php:8.2-apache

# System deps + PHP extensions used by this codebase (mysqli/PDO MySQL, curl)
# unzip/git are needed by Composer to fetch package archives — the base
# image has neither, and Composer fails outright without at least one.
RUN apt-get update \
    && apt-get install -y --no-install-recommends libcurl4-openssl-dev unzip git \
    && docker-php-ext-install mysqli pdo pdo_mysql curl \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

# Generous upload limits for product image uploads
RUN { \
        echo "upload_max_filesize=20M"; \
        echo "post_max_size=20M"; \
        echo "memory_limit=256M"; \
    } > /usr/local/etc/php/conf.d/uploads.ini

# Composer (for PHPMailer) — copy composer.json first so this layer only
# rebuilds when dependencies actually change, not on every code change
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY composer.json /var/www/html/Backend/composer.json
RUN cd /var/www/html/Backend && composer install --no-dev --optimize-autoloader --no-interaction

# Serve this folder at /Backend, matching the existing app's baseUrl paths
COPY . /var/www/html/Backend

RUN chown -R www-data:www-data /var/www/html/Backend \
    && find /var/www/html/Backend -type d -exec chmod 755 {} \; \
    && find /var/www/html/Backend -type f -exec chmod 644 {} \;

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
