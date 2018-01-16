FROM php:7.1-apache

ENV TERM xterm-256color

RUN apt-get update && apt-get install -y \
    libpq-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libxrender1 \
    libfontconfig1 \
    wget\
    nano

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql exif zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN a2enmod headers && a2enmod rewrite

ADD ./bolt.conf /etc/apache2/sites-available/000-default.conf

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update

WORKDIR /var/www

RUN rm -rf html && composer create-project bolt/composer-install:^3.4 html --prefer-dist --no-interaction

RUN chown -R www-data:www-data /var/www
