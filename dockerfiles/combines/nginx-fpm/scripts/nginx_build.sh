#!/bin/bash
#
# Env variables must be set
#   NGINX_USER
#   NGINX_GROUP
#   NGINX_VERSION
#

set -e

for env_name in "NGINX_USER" "NGINX_GROUP" "NGINX_VERSION"; do
  if [ -z ${!env_name} ]; then
    echo "Env ${env_name} must be set"
  fi
done

NGINX_GPG_SIGN_KEY=B0F4253373F8F6F510D42178520A9993A1C052F8
NGINX_INSTALL_PREFIX=/usr/local/nginx

apk add --virtual .build-deps \
		curl \
		gcc \
		gd-dev \
		gnupg \
		libc-dev \
		linux-headers \
		make \
		openssl-dev \
		pcre-dev \
		perl-dev \
		zlib-dev
		

mkdir -p ./sources
echo "Download https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
curl -fSL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o ./sources/nginx.tar.gz
echo "Download https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc"
curl -fSL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc -o ./sources/nginx.tar.gz.asc

gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$NGINX_GPG_SIGN_KEY"
gpg --verify sources/nginx.tar.gz.asc sources/nginx.tar.gz

tar -vxzC ./sources -f ./sources/nginx.tar.gz

echo "Build starting ..."
cd ./sources/nginx-${NGINX_VERSION}
./configure --prefix=${NGINX_INSTALL_PREFIX} \
	--with-http_ssl_module \
	--with-pcre \
	--with-pcre-jit \
	--with-http_stub_status_module \
	--with-http_gzip_static_module \
	--user=${NGINX_USER} \
	--group=${NGINX_GROUP}
make && make install
