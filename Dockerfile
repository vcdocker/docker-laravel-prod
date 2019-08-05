FROM php:7.2-fpm-alpine
LABEL Maintainer="Hieupv <hieupv@codersvn.com>" \
  Description="Lightweight container with Nginx & PHP-FPM for Laravel based on Alpine Linux."

RUN apk --update add wget \
  curl \
  git \
  grep \
  build-base \
  libmemcached-dev \
  libmcrypt-dev \
  libxml2-dev \
  imagemagick-dev \
  pcre-dev \
  libtool \
  make \
  autoconf \
  g++ \
  cyrus-sasl-dev \
  libgsasl-dev \
  supervisor \
  nginx

RUN docker-php-ext-install mysqli mbstring pdo pdo_mysql tokenizer xml
RUN pecl channel-update pecl.php.net \
  && pecl install memcached \
  && pecl install imagick \
  && pecl install mcrypt-1.0.1 \
  && docker-php-ext-enable memcached \
  && docker-php-ext-enable imagick \
  && docker-php-ext-enable mcrypt

# Configure nginx
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY docker/php/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY docker/php/php.ini-production /etc/php7/php.ini

RUN curl -o /usr/bin/composer https://getcomposer.org/composer.phar

RUN chmod +x /usr/bin/composer

# Configure supervisord
COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/tmp/nginx && \
  chown -R nobody.nobody /var/log/nginx 

# Setup document root
RUN mkdir -p /var/www/app

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /var/www/app
COPY --chown=nobody . /var/www/app/

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
# HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping