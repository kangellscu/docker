#!/bin/bash

set -e

# We want build a immutable service, so after inited, configuration should not be changed
if [ ! -f ${SCRIPT_DIR}/inited.lock ]; then
  # prepare configuration
  if [ -f ${CONF_DIR}/server/nginx-site.conf ]; then
    echo "Copy nginx vhost configuration files"
    cp -f ${CONF_DIR}/server/nginx-site.conf /usr/local/nginx/conf/conf.d/
  fi

  if [ -f ${CONF_DIR}/server/php.ini ]; then
    echo "Copy php.ini"
    cp -f ${CONF_DIR}/server/php.ini ${PHP_INI}
  fi

  if [ -f ${CONF_DIR}/server/fpm.conf ]; then
    echo "Copy php-fpm.d/www.conf"
    cp -f ${CONF_DIR}/server/fpm.conf ${PHP_FPM_CONF}
  fi

  if [ "${PROJECT_CONF_SCRIPT}" -a -f ${PROJECT_CONF_SCRIPT} ]; then
    echo "Process project configuration"
    /bin/bash ${PROJECT_CONF_SCRIPT}
  fi
fi

touch ${SCRIPT_DIR}/inited.lock

exec /usr/bin/supervisord -n -c /etc/supervisord.conf
