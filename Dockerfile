FROM php:7.2-fpm-alpine3.8

LABEL Maintainer Hieupv <hieupv@codersvn.com>

# Add Repositories
RUN rm -f /etc/apk/repositories &&\
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.8/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.8/community" >> /etc/apk/repositories

RUN apk add --no-cache bash \
    && apk add --no-cache --virtual .build-deps  \
    zlib-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libxml2-dev \
    bzip2-dev \
    && apk add --update --no-cache \
    jpegoptim \
    pngquant \
    optipng \
    supervisor \
    nano \
    icu-dev \
    freetype-dev \
    nginx \
    mysql-client \
    && docker-php-ext-configure \
    opcache --enable-opcache &&\
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ &&\
    docker-php-ext-install \
    opcache \
    mysqli \
    pdo \
    pdo_mysql \
    sockets \
    json \
    intl \
    gd \
    xml \
    zip \
    bz2 \
    pcntl \
    bcmath \
    mbstring \
    exif

# Add Composer
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="./vendor/bin:$PATH"

COPY ./.docker/script/script.sh /usr/bin/appup
RUN chmod +x /usr/bin/appup

COPY ./.docker/php/opcache.ini $PHP_INI_DIR/conf.d/
COPY ./.docker/php/php.ini $PHP_INI_DIR/conf.d/

# Setup Crond and Supervisor by default
RUN echo '*  *  *  *  * /usr/local/bin/php  /var/www/app/artisan schedule:run >> /dev/null 2>&1' > /etc/crontabs/root && mkdir /etc/supervisor.d
ADD ./.docker/supervisor/master.ini /etc/supervisor.d/
ADD ./.docker/nginx/default.conf /etc/nginx/conf.d/

# Remove Build Dependencies
RUN apk del -f .build-deps

# Setup Working Dir
RUN mkdir -p /var/www/app
WORKDIR /var/www/app

COPY . .

RUN cat .env.prod > .env

RUN composer install

RUN mkdir -p /var/www/app/storage/logs

RUN chmod -R 777 /var/www/app/storage

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN echo '' > auth.json

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["supervisord"]
