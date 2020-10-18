# pfcnx-laravel

Image docker from php-fpm with cron, imagemagick, zip, unzip, git, supervisor, composer, prestissimo, nodejs, yarn, prettier, xdebug and php-cs-fixer for laravel.

Can use it on [hub.docker.com](https://hub.docker.com/r/stanislasp/pfcnx-laravel/)

## Laravel Horizon
To launch the horizon just ad a new entry in your dockerfile like that :
```yml
  horizon:
    image: stanislasp/pfcnx-laravel:latest
    command: "horizon"
    volumes:
      - .:/var/www/html:rw
    depends_on:
      - your_app
    networks:
      - your_network
```
