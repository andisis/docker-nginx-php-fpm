# PHP-FPM >< Nginx on Alpine Linux

Docker image with PHP-FPM & Nginx, build on [Alpine Linux](http://www.alpinelinux.org/).

![Docker Builds](https://github.com/andisis/docker-nginx-php-fpm/workflows/Docker%20Builds/badge.svg)
![Alpine Linux 3.13](https://img.shields.io/badge/Alpine%20Linux-3.13-0E567D?style=flat-square&logo=Alpine%20Linux)
![php 7.4](https://img.shields.io/badge/php-7.4-7377AD?style=flat-square&logo=PHP)
![nginx 1.18](https://img.shields.io/badge/nginx-1.18-0D924B?style=flat-square&logo=NGINX)
![GitHub](https://img.shields.io/github/license/andisis/docker-nginx-php-fpm?style=flat-square)

## Usage

Pull this image

    docker pull andisis/nginx-php-fpm

Start the Docker container:

    docker run -d -p 80:80 andisis/nginx-php-fpm

See the PHP info on http://localhost, or the static html page on http://localhost/hello.html

Or mount your own code to be served by PHP-FPM & Nginx

    docker run -p 80:80 -v <your_project>:/var/www/html andisis/nginx-php-fpm

## With custom configuration

In [config](https://github.com/andisis/docker-nginx-php-fpm/tree/master/config) folder you'll find the default configuration files for Nginx, PHP and PHP-FPM.
If you want to extend or customize that you can do so by mounting a configuration file in the correct folder;

Nginx configuration:

    docker run -v "<your_config_directory>/your-nginx.conf:/etc/nginx/conf.d/server.conf" andisis/nginx-php-fpm

PHP configuration:

    docker run -v "<your_config_directory>/your-php.ini:/etc/php7/conf.d/settings.ini" andisis/nginx-php-fpm

PHP-FPM configuration:

    docker run -v "<your_config_directory>/your-php-fpm.conf:/etc/php7/php-fpm.d/server.conf" andisis/nginx-php-fpm

## Using as base image

If you want to use this image as a base image on your Dockerfile, here's an easy way to add it:

```dockerfile
# Example if use this image for the laravel project
FROM andisis/nginx-php-fpm:latest

# Laravel use public folder for document root
ENV SERVER_ROOT=/var/www/html/public

# Copy project
ADD . /var/www/html

# Change workdir permission
RUN chown -R www-data.www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod -R 777 /var/www/html/storage && \
    # Install library using composer
    composer install && \
    # Copy environments (Alternatively you can copy from static .env files you have been created)
    cp /var/www/html/.env.example /var/www/html/.env && \
    # Generate application key
    php artisan key:generate

# Run db migration if you need
# RUN php artisan migrate
```

If you want to add other packages like MongoDB, MySQL or PostgreSQL, just create your own image like this

```dockerfile
# Example if use this image for the laravel project
FROM andisis/nginx-php-fpm:latest

# Add alpine 3.6 repository to install mongodb
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.6/main' >> /etc/apk/repositories && \
    echo 'http://dl-cdn.alpinelinux.org/alpine/v3.6/community' >> /etc/apk/repositories

# Install mongodb / mysql / postgresql
RUN apk add --no-cache --update \
    mongodb=3.4.4-r0 \
    php7-mysqli \
    php7-pdo_mysql
    php7-pgsql \
    php7-pdo_pgsql \
    php7-mongodb


# Laravel use public folder for document root
ENV SERVER_ROOT=/var/www/html/public

# Copy project
ADD . /var/www/html

# Change workdir permission
RUN chown -R www-data.www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod -R 777 /var/www/html/storage && \
    # Install library using composer
    composer install && \
    # Copy environments (Alternatively you can copy from static .env files you have been created)
    cp /var/www/html/.env.example /var/www/html/.env && \
    # Generate application key
    php artisan key:generate

# Run db migration if you need
# RUN php artisan migrate
```