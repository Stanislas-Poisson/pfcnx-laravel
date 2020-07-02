FROM php:7.3-fpm

# Dependencies
RUN apt-get update \
    && apt-get install -y \
        libmcrypt-dev \
        libpq-dev \
        libicu-dev \
        zlib1g-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libjpeg-dev \
        libpng-dev \
        libmcrypt-dev \
        libzip-dev \
        gnupg \
        vim \
        cron \
        imagemagick \
        locales \
        zip \
        unzip \
        git \
        supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install --global --save-exact yarn \
    && npm install --global --save-exact prettier \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
        intl \
        bcmath \
        gd \
        mysqli \
        mbstring \
        exif \
        opcache \
        pdo_mysql \
        json \
        pcntl \
        zip

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin \
    composer global require "hirak/prestissimo:^0.3"

# Xdebug
RUN pecl install -o -f xdebug-2.7.2 \
    && pecl install -o -f redis-5.0.5 \
    && docker-php-ext-enable redis \
    && rm -rf /tmp/pear

# PHP-CS-Fixer
RUN curl -sL http://cs.sensiolabs.org/download/php-cs-fixer-v2.phar -o php-cs-fixer \
    && chmod a+x php-cs-fixer \
    && mv php-cs-fixer /usr/local/bin/php-cs-fixer

# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr
ENV LC_ALL fr_FR.UTF-8

# Configuration
COPY conf/php.ini /usr/local/etc/php/php.ini
COPY conf/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY conf/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0777 /usr/local/bin/entrypoint.sh
COPY conf/supervisord.conf /etc/supervisord.conf

# Cron
RUN touch /var/log/cron.log
COPY conf/crontab /etc/cron.d/app
RUN chmod 0644 -R /etc/cron.d/
RUN chmod +x -R /etc/cron.d/
RUN crontab -u www-data /etc/cron.d/app

EXPOSE 9000
EXPOSE 8000
EXPOSE 3000
EXPOSE 3001
WORKDIR /var/www/html

VOLUME ["/var/www/html"]
CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
