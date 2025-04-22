FROM php:8.3-fpm-alpine

ARG USER_ID
ARG GROUP_ID

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    deluser www-data && adduser -DH -h /home/www-data -s /sbin/nologin -u ${USER_ID} www-data && \
    mkdir -p /home/www-data/.config &&\
    mkdir -p /home/www-data/.composer &&\
    mkdir -p /home/www-data/.npm && \
    chown --changes --silent --no-dereference --recursive \
         ${USER_ID}:${GROUP_ID} \
        /home/www-data \
        /home/www-data/.config \
        /home/www-data/.composer \
        /home/www-data/.npm \
    ;fi 

COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN mkdir -p /.composer; chmod 777 /.composer

WORKDIR /var/www/html
RUN echo "UTC" > /etc/timezone

RUN curl -O https://download.microsoft.com/download/b/9/f/b9f3cce4-3925-46d4-9f46-da08869c6486/msodbcsql18_18.0.1.1-1_amd64.apk
RUN curl -O https://download.microsoft.com/download/b/9/f/b9f3cce4-3925-46d4-9f46-da08869c6486/mssql-tools18_18.0.1.1-1_amd64.apk
RUN apk add --allow-untrusted msodbcsql18_18.0.1.1-1_amd64.apk
RUN apk add --allow-untrusted mssql-tools18_18.0.1.1-1_amd64.apk
RUN rm msodbcsql18_18.0.1.1-1_amd64.apk
RUN rm mssql-tools18_18.0.1.1-1_amd64.apk

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

RUN apk update \
    && apk add --no-cache linux-headers gettext-dev libwebp-dev zlib-dev icu-dev libxpm-dev freetype-dev libjpeg-turbo-dev libpng-dev libxml2-dev libzip-dev bzip2-dev unixodbc-dev libmemcached-dev libstdc++ openssl-dev gcc g++ make autoconf \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure sockets \
    && docker-php-ext-install -j$(nproc) sockets \
    && docker-php-ext-configure exif \
    && docker-php-ext-install -j$(nproc) exif \
    && docker-php-ext-configure pdo_mysql \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-configure bz2 \
    && docker-php-ext-install -j$(nproc) bz2 \
    && docker-php-ext-configure mysqli \
    && docker-php-ext-install -j$(nproc) mysqli \
    && docker-php-ext-configure gettext \
    && docker-php-ext-install -j$(nproc) gettext \
    && docker-php-ext-configure xml \
    && docker-php-ext-install -j$(nproc) xml \
    && docker-php-ext-configure bcmath \
    && docker-php-ext-install -j$(nproc) bcmath \
    && docker-php-ext-configure pcntl \
    && docker-php-ext-install -j$(nproc) pcntl \
    && docker-php-ext-configure opcache \
    && docker-php-ext-install -j$(nproc) opcache \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-enable intl

RUN pecl install redis \
    && docker-php-ext-enable redis

RUN pecl install memcached \
    && docker-php-ext-enable memcached

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

RUN pecl install sqlsrv-5.10.0 \
    && docker-php-ext-enable sqlsrv

RUN pecl install pdo_sqlsrv-5.10.0 \
    && docker-php-ext-enable pdo_sqlsrv

RUN apk add --update nodejs
RUN mkdir -p /.npm && chmod -R 777 /.npm
RUN apk add --update npm
RUN apk add --update yarn
RUN apk add --update mysql-client mariadb-connector-c-dev
#RUN npm i -g @vue/cli
#RUN npm i -g create-nuxt-app
#RUN npm i -g pm2

RUN apk del gcc g++ make autoconf
RUN rm /var/cache/apk/*
