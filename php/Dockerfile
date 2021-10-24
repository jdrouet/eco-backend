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

COPY . /code
COPY --from=builder /code/vendor /code/vendor
WORKDIR /code

CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
