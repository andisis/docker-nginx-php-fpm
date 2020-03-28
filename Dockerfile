FROM alpine:latest

LABEL maintainer="Andi Siswanto <andisis92@gmail.com> | https://andisiswanto.com"

# Create user
RUN adduser -D -u 1000 -g 1000 -s /bin/sh www-data

# Install tini & make
RUN apk add --no-cache --update tini make curl

# Install a golang port of supervisord
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/bin/supervisord

# Install nginx & gettext (envsubst)
# Create cachedir and fix permissions
RUN apk add --no-cache --update \
    gettext \
    nginx && \
    mkdir -p /var/cache/nginx

# Install PHP/FPM + Modules
RUN apk add --no-cache --update \
    php7-apcu \
    php7-bcmath \
    php7-bz2 \
    php7-cgi \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-fileinfo \
    php7-fpm \
    php7-ftp \
    php7-gd \
    php7-iconv \
    php7-json \
    php7-mbstring \
    php7-oauth \
    php7-opcache \
    php7-openssl \
    php7-pcntl \
    php7-pdo \
    php7-phar \
    php7-redis \
    php7-session \
    php7-simplexml \
    php7-tokenizer \
    php7-xdebug \
    php7-xml \
    php7-xmlwriter \
    php7-zip \
    php7-zlib \
    php7-zmq

# Install composer from the official image
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Runtime env vars are envstub'd into config during entrypoint
ENV SERVER_ALIAS=""
ENV SERVER_NAME="localhost"
ENV SERVER_ROOT=/var/www/html

# Configure runner command
COPY config/default-entrypoint.sh /entrypoint.sh

# Configure nginx & Remove default server config definition
COPY config/default-nginx.conf /docker-nginx.conf
RUN rm /etc/nginx/conf.d/default.conf

# Configure PHP-FPM
COPY config/default-fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/default-php.ini /etc/php7/conf.d/custom.ini

# Configure supervisord
COPY config/default-supervisord.conf /supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

# Make sure files/folders needed by the processes are accessable when they run under the www-data user
RUN chown -R www-data.www-data /var/www/html && \
    chown -R www-data.www-data /run && \
    chown -R www-data:www-data /var/cache/nginx && \
    chown -R www-data.www-data /var/lib/nginx && \
    chown -R www-data.www-data /var/log/nginx

# Make the document root a volume
VOLUME /var/www/html

# Add default application
WORKDIR /var/www/html
COPY src/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 80

# Run application
ENTRYPOINT ["tini", "--", "/entrypoint.sh"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1/fpm-ping
