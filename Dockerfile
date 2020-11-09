FROM php:7.2-fpm-stretch

MAINTAINER Deon Thomas "Deon.Thomas.GY@gmail.com"

# Install modules -
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libwebp-dev \
        libpng-dev \
        libmagickwand-6.q16-dev \
        gnupg \
    && ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin \
    && pecl install imagick \
    && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
    && pecl install mcrypt-1.0.1 \
    && docker-php-ext-install iconv pdo_mysql bcmath exif sockets \
    && docker-php-ext-configure gd --enable-shared --with-webp-dir=/usr/include/ --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd zip mysqli intl\
    && docker-php-ext-enable mcrypt \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# Install igbinary (for more efficient serialization in redis/memcached)
RUN for i in $(seq 1 3); do pecl install -o igbinary && s=0 && break || s=$? && sleep 1; done; (exit $s) \
    && docker-php-ext-enable igbinary

# Install redis (manualy build in order to be able to enable igbinary)
RUN for i in $(seq 1 3); do pecl install -o --nobuild redis && s=0 && break || s=$? && sleep 1; done; (exit $s) \
    && cd "$(pecl config-get temp_dir)/redis" \
    && phpize \
    && ./configure --enable-redis-igbinary \
    && make \
    && make install \
    && docker-php-ext-enable redis \
    && cd -


# Microsoft SQL Server Prerequisites
# Credits: https://laravel-news.com/install-microsoft-sql-drivers-php-7-docker
ENV ACCEPT_EULA=Y

RUN apt-get update \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/9/prod.list \
        > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get install -y --no-install-recommends \
        locales \
        apt-transport-https \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        unixodbc-dev \
        msodbcsql17

RUN pecl install sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv

RUN echo "php_value[memory_limit] = 512M" >> /usr/local/etc/php-fpm.conf
RUN echo "php_value[date.timezone] = America/Guyana" >> /usr/local/etc/php-fpm.conf
RUN echo "php_value[upload_max_filesize] = 1024M" >> /usr/local/etc/php-fpm.conf
RUN echo "php_value[post_max_size] = 1024M" >> /usr/local/etc/php-fpm.conf
RUN echo 'max_execution_time = 1200' >> /usr/local/etc/php/conf.d/docker-php-maxexectime.ini;
#RUN sed -e 's/max_execution_time = 30/max_execution_time = 360/' -i  /usr/local/etc/php/php.ini-development
#RUN sed -e 's/max_execution_time = 30/max_execution_time = 360/' -i  /usr/local/etc/php/php.ini-production
RUN sed -e 's/memory_limit = 128M/memory_limit = 512M/' -i  /usr/local/etc/php/php.ini-production
RUN sed -e 's/memory_limit = 128M/memory_limit = 512M/' -i  /usr/local/etc/php/php.ini-development
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

CMD ["php-fpm"]
