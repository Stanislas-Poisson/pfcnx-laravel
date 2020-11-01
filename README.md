# pfcnx-laravel

Image docker from php-fpm with cron, imagemagick, zip, unzip, git, supervisor, composer, prestissimo, nodejs, yarn, prettier, xdebug and php-cs-fixer for laravel.

Can use it on [hub.docker.com](https://hub.docker.com/r/stanislasp/pfcnx-laravel/)

## Exemple of docker-compose
```yml
version: "3"

services:
# Nginx Service
  webserver:
    image: nginx:alpine
    container_name: dk_myapp_webserver
    restart: unless-stopped
    tty: true
    ports:
      - 80:80
      - 443:443
      - 8080:8080
    volumes:
      - ./:/var/www
      - ./.docker/nginx/conf.d/:/etc/nginx/conf.d/
    networks:
      - myApp-network

# PHP Service
  app:
    build:
      context: .
      dockerfile: .docker/php/Dockerfile
    container_name: dk_myapp_app
    restart: unless-stopped
    tty: true
    links:
      - database
      - redis
      - mailcatcher
    volumes:
      - ./:/var/www
      - ./.docker/php/conf/php.ini:/usr/local/etc/php/conf.d/php.ini
      - ./.docker/php/conf/xdebug.ini:/usr/local/etc/php/conf.d/xdebug.ini
    networks:
      - myApp-network

  horizon:
    build:
      context: .
      dockerfile: .docker/php/Dockerfile
    container_name: dk_myapp_horizon
    restart: unless-stopped
    tty: true
    depends_on:
      - database
      - redis
    volumes:
      - ./:/var/www
      - ./.docker/php/conf/php.ini:/usr/local/etc/php/conf.d/php.ini
      - ./.docker/php/conf/xdebug.ini:/usr/local/etc/php/conf.d/xdebug.ini
    command: php artisan horizon
    networks:
      - myApp-network

  # Cron Service
  ofelia-cron:
    build:
      context: ./.docker/cron
    container_name: dk_myapp_cron
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./.docker/cron/timezone:/etc/timezone
      - ./.docker/cron/localtime:/etc/localtime
    networks:
      - myApp-network

  # MySQL Service
  database:
    image: mysql:5.7
    container_name: dk_myapp_database
    restart: unless-stopped
    tty: true
    ports:
      - 3306:3306
    env_file: .env
    volumes:
      - myAppData-database:/var/lib/mysql/
      - ./.docker/mysql/conf:/etc/mysql/conf.d/custom.cnf:ro
    networks:
      - myApp-network

  # Redis Service
  redis:
    image: redis:5-alpine
    container_name: dk_myapp_redis
    command: redis-server --appendonly yes
    env_file: .env
    hostname: redis
    ports:
      - 6379:6379
    volumes:
      - myAppData-redis:/data
    networks:
      - myApp-network

  # MailCatcher Service
  mailcatcher:
    image: jeanberu/mailcatcher:0.7.1
    container_name: dk_myapp_mailcatcher
    ports:
      - 1025:1025
      - 1080:1080
    networks:
      - myApp-network

  # Selenium Services
  selenium-hub:
    image: selenium/hub:4.0.0-alpha-7-prerelease-20201009
    container_name: dk_myapp_selenium_hub
    ports:
      - 4442:4442
      - 4443:4443
      - 4444:4444
    networks:
      - myApp-network

  selenium-chrome:
    image: selenium/node-chrome:4.0.0-alpha-7-prerelease-20201009
    volumes:
      - /dev/shm:/dev/shm
    depends_on:
      - selenium-hub
    environment:
      - SE_EVENT_BUS_HOST=dk_myapp_selenium_hub
      - SE_EVENT_BUS_PUBLISH_PORT=4442
      - SE_EVENT_BUS_SUBSCRIBE_PORT=4443
    ports:
      - 6900:5900
    networks:
      - myApp-network

#Docker Networks
networks:
  myApp-network:
    driver: bridge

#Volumes
volumes:
  myAppData-database:
    driver: local
  myAppData-redis:
    driver: local
```
