FROM php:7.4-fpm

# Dependencies
RUN apt-get update \
    && apt-get install -y \
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
    gnupg \
    vim \
    cron \
    imagemagick \
    locales \
    zip \
    unzip \
    git \
    supervisor \
    curl \
    wget \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Composer and parallel to speed up the installation process.
RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin \
    composer global require "hirak/prestissimo:^0.3"

# PHP-CS-Fixer
RUN curl -sL http://cs.sensiolabs.org/download/php-cs-fixer-v2.phar -o php-cs-fixer \
    && chmod a+x php-cs-fixer \
    && mv php-cs-fixer /usr/local/bin/php-cs-fixer

# Xdebug and Redis
RUN pecl install -o -f xdebug-2.8.0 \
    && pecl install -o -f redis-6.0.8 \
    && rm -rf /tmp/pear

# Php Extensions
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
    && docker-php-ext-enable redis

# Node.js, Npm, Yarn and Prettier
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install --global --save-exact yarn \
    && npm install --global --save-exact prettier \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable xvfb libnss3-dev libxi6 libgconf-2-4 \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
COPY conf/supervisord-horizon.conf /etc/supervisord-horizon.conf

# Cron
RUN touch /var/log/cron.log
COPY conf/crontab /etc/cron.d/app
RUN chmod 0644 -R /etc/cron.d/
RUN chmod +x -R /etc/cron.d/
RUN crontab -u www-data /etc/cron.d/app

EXPOSE 9515 9000 8000 3000 3001
WORKDIR /var/www/html

VOLUME ["/var/www/html"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]
