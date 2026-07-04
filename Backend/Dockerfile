FROM php:8.2-apache

# System deps + PHP extensions used by this codebase (mysqli/PDO MySQL, curl)
RUN apt-get update \
    && apt-get install -y --no-install-recommends libcurl4-openssl-dev \
    && docker-php-ext-install mysqli pdo pdo_mysql curl \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

# Generous upload limits for product image uploads
RUN { \
        echo "upload_max_filesize=20M"; \
        echo "post_max_size=20M"; \
        echo "memory_limit=256M"; \
    } > /usr/local/etc/php/conf.d/uploads.ini

# Serve this folder at /Backend, matching the existing app's baseUrl paths
COPY . /var/www/html/Backend

RUN chown -R www-data:www-data /var/www/html/Backend \
    && find /var/www/html/Backend -type d -exec chmod 755 {} \; \
    && find /var/www/html/Backend -type f -exec chmod 644 {} \;

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
