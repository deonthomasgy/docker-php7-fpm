FROM php:7.2-fpm-stretch

MAINTAINER Deon Thomas "Deon.Thomas.GY@gmail.com"

# Install modules
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libmagickwand-6.q16-dev \
    && ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin \
    && pecl install imagick \
    && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
    && pecl install mcrypt-1.0.1 \
    && docker-php-ext-install iconv pdo_mysql bcmath exif \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd zip \
    && docker-php-ext-enable mcrypt \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

RUN echo "php_value[memory_limit] = 512M" >> /usr/local/etc/php-fpm.conf
RUN echo "php_value[date.timezone] = America/Guyana" >> /usr/local/etc/php-fpm.conf
RUN echo "php_value[upload_max_filesize] = 1024M" >> /usr/local/etc/php-fpm.conf
RUN echo "php_value[post_max_size] = 1024M" >> /usr/local/etc/php-fpm.conf


CMD ["php-fpm"]
