#!/bin/bash

set -e

# prepare configuration
if [ -d ${NGINX_CONF_VHOST_DIR} ]; then
  echo "Copy nginx vhost configuration files"
  rm -rf /usr/local/nginx/conf/conf.d/*
  cp -f ${NGINX_CONF_VHOST_DIR}/*.conf ${CUSTOM_PREFIX}/nginx/conf/conf.d/

if [ -d ${PHP_CONF_DIR} ]; then
  echo "Copy php.ini into ini.d/"
  cp -f ${PHP_CONF_DIR}/*.ini ${CUSTOM_PREFIX}/php/etc/ini.d/
fi
if [ -f ${PHP_FPM_CONF_DIR} ]; then
  echo "Copy php-fpm.d/*.conf"
  cp -f ${PHP_FPM_CONF_DIR}/*.conf ${CUSTOM_PREFIX}/php/etc/php-fpm.d/
fi
