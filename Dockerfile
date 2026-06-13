FROM php:8.4-apache

RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev \
    && docker-php-ext-install pdo pdo_pgsql zip

RUN a2enmod rewrite

WORKDIR /var/www/html

COPY . .

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN composer install --no-dev --optimize-autoloader

RUN chown -R www-data:www-data /var/www/html

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
 /etc/apache2/sites-available/*.conf

RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' \
 /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

EXPOSE 80

CMD ["apache2-foreground"]