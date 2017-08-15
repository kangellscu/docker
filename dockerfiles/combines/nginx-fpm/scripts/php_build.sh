#!/bin/bash
#
# Env variables must be set
#   PHP_VERSION
#   SERVER_USER
#   SERVER_GROUP

set -e

for env_name in "SERVER_USER" "SERVER_GROUP" "PHP_VERSION"; do
  if [ -z ${!env_name} ]; then
    echo "Env ${env_name} must be set"
  fi
done

CURL_VERSION=7.55.0

mkdir -p ./sources
basedir=`pwd`

echo "Install php ${PHP_VERSION} starting ..."
echo "Install required libs"
apk add \
	autoconf \
  bzip2-dev \
  freetype-dev \
	gcc \
	gdbm-dev \
	gd-dev \
	gettext-dev \
  gmp-dev \
	g++ \
	icu-dev \
	libc-dev \
  libcurl \
  libedit-dev \
  libidn-dev \
  libjpeg-turbo-dev \
	libmcrypt-dev \
	libpng-dev \
	libvpx-dev \
	libxml2-dev \
	libxslt-dev \
	libxpm-dev \
	linux-headers \
	make \
	m4 \
	openssl-dev \
	readline-dev \
  re2c \
	tidyhtml-dev \
	zlib-dev

echo "Install curl without NSS"
# download
curl -fSL https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz -o ./sources/curl.tar.gz
#https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz.asc -o ./sources/curl.tar.gz.asc
#gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$CURL_GPG_SIGN_KEY"
#gpg --verify sources/curl.tar.gz.asc sources/curl.tar.gz

# install curl without nss
tar -vxzC ./sources -f ./sources/curl.tar.gz
cd ./sources/curl-${CURL_VERSION}
./configure --prefix=${CUSTOM_PREFIX}/curl --without-nss
make && make install
cd $basedir

echo "Install php software"
curl -fSL http://cn2.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror -o ./sources/php.tar.gz
tar -vxzC ./sources -f ./sources/php.tar.gz
cd ./sources/php-${PHP_VERSION}

./configure --prefix=${CUSTOM_PREFIX}/php \
	  --enable-bcmath \
	  --enable-calendar \
	  --enable-dba \
	  --enable-exif \
	  --enable-fpm \
	  --enable-ftp \
	  --enable-intl \
	  --enable-mbstring \
	  --enable-mysqlnd \
	  --enable-opcache \
	  --enable-pcntl \
	  --enable-shared \
	  --enable-soap \
	  --enable-sockets \
	  --enable-sysvmsg \
	  --enable-sysvsem \
	  --enable-sysvshm \
	  --with-bz2 \
	  --with-config-file-path=${CUSTOM_PREFIX}/php/etc \
	  --with-config-file-scan-dir=${CUSTOM_PREFIX}/php/etc/ini.d \
	  --with-curl=/usr/local \
	  --with-fpm-user=${SERVER_USER} \
	  --with-fpm-group=${SERVER_GROUP} \
	  --with-freetype-dir \
	  --with-gd \
	  --with-gdbm \
	  --with-gettext \
	  --with-gmp \
	  --with-iconv-dir \
    --with-ldap \
    --with-ldap-sasl \
	  --with-jpeg-dir \
	  --with-libdir=lib64 \
	  --with-libedit \
	  --with-libxml-dir \
	  --with-mcrypt \
	  --with-mhash \
	  --with-mysql-sock=/tmp/mysql.sock \
	  --with-mysqli=shared,mysqlnd \
	  --with-openssl \
	  --with-openssl-dir \
	  --with-pdo-mysql=shared,mysqlnd \
	  --with-png-dir \
	  --with-readline \
	  --with-tidy \
	  --with-xpm-dir \
	  --with-xsl \
	  --with-zlib \
	  --with-zlib-dir

make && make install

echo "Copy php.ini-production"
cp php.ini-production ${CUSTOM_PREFIX}/php/etc/php.ini
mkdir -p ${CUSTOM_PREFIX}/php/etc/ini.d
export PATH=$PATH:${CUSTOM_PREFIX}/php/bin

echo "Install mongodb extension"
pecl channel-update pecl.php.net
pecl install mongodb
echo "extension=mongodb.so" >> ${CUSTOM_PREFIX}/php/etc/ini.d/mongodb.ini
