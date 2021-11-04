FROM composer:2.1 AS builder

WORKDIR /code
COPY composer.json composer.lock /code/
RUN composer install --no-dev

FROM php:7.4-apache-bullseye

RUN apt-get update \
    && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && rm -rf /var/lib/apt/lists/*

ENV APP_NAME=eco-backend
ENV APP_ENV=production
ENV APP_DEBUG=false

RUN sed -i -e "s/\/var\/www\/html/\/var\/www\/public/g" /etc/apache2/sites-enabled/000-default.conf
RUN a2enmod rewrite

COPY . /var/www
COPY --from=builder /code /var/www
RUN chown -R www-data:www-data /var/www
