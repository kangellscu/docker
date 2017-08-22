#!/bin/bash

set -e

PHP_MONGODB_VERSION=1.2.9

# make sure phpize available
apk add --virtual .phpext-deps autoconf \
  m4 \
  gcc \
  g++

apk add \
  curl \
  gd-dev \
  geoip-dev \
  freetype-dev \
  icu-dev \
  libc-dev \
  linux-headers \
  libmcrypt-dev \
  libpng-dev \
  libxml2-dev \
  libxslt-dev \
  make \
  openjpeg-dev \
  openssl-dev \
  pcre-dev \
  perl-dev \
  sqlite-dev \
  zlib-dev

echo "Manual install mongodb extension"
cd ${BUILD_DIR}
mkdir -p ./sources
curl -fSL https://pecl.php.net/get/mongodb-${PHP_MONGODB_VERSION}.tgz -o ./sources/mongodb.tar.gz
tar -vxzC ./sources -f ./sources/mongodb.tar.gz
cd ./sources/mongodb-${PHP_MONGODB_VERSION}
phpize
./configure
make && make test && make install
docker-php-ext-enable mongodb

EXTLIB=" \
  dom \
  exif \
  gd \
  intl \
  json \
  mcrypt \
  mysqli \
  pdo_mysql \
  pdo_sqlite \
  soap \
  xsl \
  zip \
"

docker-php-ext-install $EXTLIB opcache
docker-php-source delete

apk del .phpext-deps

# php.ini
echo "Create php.ini"
echo "upload_max_filesize = 100M" >> ${PHP_INI}
echo "post_max_size = 100M" >> ${PHP_INI}
echo "variables_order = \"EGPCS\""  >> ${PHP_INI}
echo "memory_limit = 128M"  >> ${PHP_INI}

# www.conf
echo "Modify php-fpm.d/www.conf"

sed -i \
  -e "s#;error_log = log/php-fpm.log#error_log = ${LOG_DIR}/fpm.log#g" \
  /usr/local/etc/php-fpm.conf

rm -rf /usr/local/etc/php-fpm.d/*.conf
sed \
  -e "s/;catch_workers_output = yes/catch_workers_output = yes/g" \
  -e "s/;pm.max_requests = 500/pm.max_requests = 200/g" \
  -e "s/user = www-data/user = ${SERVER_USER}/g" \
  -e "s/group = www-data/group = ${SERVER_GROUP}/g" \
  -e "s/;listen.owner = www-data/listen.owner = ${SERVER_USER}/g" \
  -e "s/;listen.group = www-data/listen.group = ${SERVER_GROUP}/g" \
  -e "s#listen = 127.0.0.1:9000#listen = ${PHP_FPM_SOCK}#g" \
  -e "s/^;clear_env = no$/clear_env = no/" \
  ${PHP_FPM_CONF}.default > ${PHP_FPM_CONF}
