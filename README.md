# PHP-FPM 7.x

PHP-FPM (FastCGI Process Manager) is an alternative PHP FastCGI implementation with some additional features useful for sites of any size, especially busier sites. 

This Container includes the following extensions:
  - iconv
  - mcrypt
  - pdo_mysql
  - bcmath
  - gd
  - imagick
  - exif
  - mysqli
  - intl
# Installation
The following command will pull the latest php-fpm build.
```sh
$ docker pull princeamd/php-fpm:latest
```
# Create Container
The following command creates a container with php-fpm that's available on port: 9000.
```sh
docker run --name thomas-php -h php -v /etc/localtime:/etc/localtime:ro -d princeamd/php-fpm:latest
```
License
---
MIT
