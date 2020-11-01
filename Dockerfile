FROM php:7.4-fpm

# Set working directory
WORKDIR /var/www
VOLUME ["/var/www"]

# Dependencies of unix, Install composer, PHP-CS-Fixer, Node.js, Npm, Yarn, Prettier, Xdebug and Redis
RUN apt-get update \
    && apt-get install -y \
    build-essential \
    jpegoptim optipng pngquant gifsicle \
    libcurl4-gnutls-dev \
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
    libonig-dev \
    libnss3 \
    libx11-6 \
    libx11-xcb1 \
    libxml2-dev \
    gnupg \
    vim \
    nano \
    imagemagick \
    locales \
    zip \
    unzip \
    git \
    curl \
    wget \
    # Install composer and a plugin for parallel installation and speed up the install
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    # && composer global require "hirak/prestissimo" \
    # PHP-CS-Fixer
    && curl -sL http://cs.sensiolabs.org/download/php-cs-fixer-v2.phar -o php-cs-fixer \
    && chmod a+x php-cs-fixer \
    && mv php-cs-fixer /usr/local/bin/php-cs-fixer \
    # Node.js
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    # Yarn
    && npm install --global --save-exact yarn \
    # Prettier
    && npm install --global --save-exact prettier \
    # Configure for stable version
    && pear config-set preferred_state stable \
    # Xdebug
    && pecl install -o -f xdebug \
    # Redis
    && pecl install -o -f redis \
    # Cleaning the image step
    && rm -rf /tmp/pear \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install extensions
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
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
    zip \
    curl \
    dom \
    xml \
    && docker-php-ext-enable redis

# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr
ENV LC_ALL fr_FR.UTF-8

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
