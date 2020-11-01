#!/bin/bash

if grep -Fxq "APP_KEY=" /var/www/.env
then
    php artisan key:generate
fi

php artisan config:cache
php artisan clear-compiled
