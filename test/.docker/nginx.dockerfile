FROM nginx:1.15
ADD ./nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./nginx/conf.d/ /etc/nginx/conf.d/


# Add phpMyAdmin
# ARG PHP_MYADMIN_INSTALL_DIR=/var/www/phpmyadmin
# ARG DOWNLOAD_URL=file:///tmp/phpMyAdmin-4.8.1-english.tar.gz

# COPY . /tmp

# RUN mkdir -p "${PHP_MYADMIN_INSTALL_DIR}"
# RUN tar -xvzf /tmp/phpMyAdmin-4.8.1-english.tar.gz -C "${PHP_MYADMIN_INSTALL_DIR}"
