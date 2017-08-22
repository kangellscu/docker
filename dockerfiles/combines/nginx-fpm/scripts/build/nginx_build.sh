#!/bin/bash
#
# Env variables must be set
#   SERVER_USER
#   SERVER_GROUP
#   NGINX_VERSION
#

set -e

for env_name in "BUILD_DIR" "SERVER_USER" "SERVER_GROUP" "NGINX_VERSION"; do
  if [ -z ${!env_name} ]; then
    echo "Env ${env_name} must be set"
  fi
done

NGINX_GPG_SIGN_KEY=B0F4253373F8F6F510D42178520A9993A1C052F8
NGINX_INSTALL_PREFIX=${CUSTOM_PREFIX}/nginx

apk add curl \
		gcc \
		gd-dev \
    geoip-dev \
		gnupg \
		libc-dev \
		linux-headers \
		make \
		openssl-dev \
		pcre-dev \
		perl-dev \
		zlib-dev
		

cd ${BUILD_DIR}
mkdir -p ./sources
echo "Download https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
curl -fSL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o ./sources/nginx.tar.gz
#echo "Download https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc"
#curl -fSL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc -o ${BUILD_DIR}/sources/nginx.tar.gz.asc

#gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$NGINX_GPG_SIGN_KEY"
#gpg --verify ./sources/nginx.tar.gz.asc ./sources/nginx.tar.gz

tar -vxzC ./sources -f ./sources/nginx.tar.gz

echo "Build starting ..."
cd ./sources/nginx-${NGINX_VERSION}
./configure --prefix=${NGINX_INSTALL_PREFIX} \
  --with-http_geoip_module=dynamic \
  --with-http_gunzip_module \
	--with-http_gzip_static_module \
  --with-http_perl_module=dynamic \
  --with-http_realip_module \
	--with-http_ssl_module \
	--with-http_stub_status_module \
  --with-http_v2_module \
	--with-pcre \
	--with-pcre-jit \
  --with-threads

make && make install

echo "Copy default nginx.conf & nginx-site.conf"
NGINX_CONF=${NGINX_INSTALL_PREFIX}/conf/nginx.conf
cp -f ${BUILD_DIR}/conf/nginx.conf ${NGINX_CONF}
sed -i \
  -e "s/user nobody/user ${SERVER_USER}/g" \
  -e "s@access_log  logs/access.log  main@access_log ${LOG_DIR}/nginx_access.log main@g" \
  -e "s@error_log logs/error.log@error_log ${LOG_DIR}/nginx_error.log@g" \
  ${NGINX_CONF}

mkdir -p ${NGINX_INSTALL_PREFIX}/conf/conf.d
cp -f ${BUILD_DIR}/conf/nginx-site.conf ${NGINX_INSTALL_PREFIX}/conf/conf.d/
