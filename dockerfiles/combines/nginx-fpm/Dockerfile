# Usage:
# docker build --build-arg NGINX_VERSION=1.13.4 -t <name> .

# build nginx & php
FROM php:7.1.8-fpm-alpine AS nginx
ARG USER
ARG GROUP
ARG NGINX_VERSION

ENV BUILD_DIR=/data/build \
  CONF_DIR=/data/conf \
  CUSTOM_PREFIX=/usr/local \
  LOG_DIR=/usr/local/var/log \
  NGINX_VERSION=${NGINX_VERSION} \
  SCRIPT_DIR=/data/scripts \
  SERVER_GROUP=${GROUP:-www} \
	SERVER_USER=${USER:-www}

COPY scripts/build ${BUILD_DIR}/scripts
COPY conf/nginx.conf \
  conf/nginx-site.conf \
  ${BUILD_DIR}/conf/

RUN /bin/sh ${BUILD_DIR}/scripts/bash_install.sh \
  && /bin/bash ${BUILD_DIR}/scripts/nginx_build.sh


FROM php:7.1.8-fpm-alpine
ARG USER
ARG GROUP

LABEL author=leikou \
      email=leikouscu@gmail.com \
      build_usage="docker build \
        --build-arg NGINX_VERSION=1.13.4 \
        <--build-arg USER=www> \
        <--build-arg GROUP=www> \
        -t <name> ." \
      run_usage="docker run \
        <-v /path/to/ext_conf:${CONF_DIR}> \
        <-v /path/to/ext_log:{LOG_DIR}> \
        -p host_port:80 \
        -p host_port:443 \
        <image_name>"

ENV BUILD_DIR=/data/build \
  CONF_DIR=/data/conf \
  LOG_DIR=/usr/local/var/log \
  PHP_INI=/usr/local/etc/php/conf.d/docker-vars.ini \
  PHP_FPM_CONF=/usr/local/etc/php-fpm.d/www.conf \
  PHP_FPM_SOCK=/usr/local/var/run/php-fpm.sock \
  SCRIPT_DIR=/data/scripts \
  SERVER_GROUP=${GROUP:-www} \
	SERVER_USER=${USER:-www} \
  WWW_ROOT=/var/www

COPY --from=nginx /usr/local/nginx /usr/local/nginx/
COPY scripts/build/bash_install.sh \
  scripts/build/php_extension.sh \
  scripts/build/supervisor.sh \
  ${BUILD_DIR}/scripts/
COPY scripts/run ${SCRIPT_DIR}
COPY conf/supervisor* ${BUILD_DIR}/conf/

RUN /bin/sh ${BUILD_DIR}/scripts/bash_install.sh \
  && /bin/bash ${BUILD_DIR}/scripts/php_extension.sh \
  && /bin/bash ${BUILD_DIR}/scripts/supervisor.sh \
  && /bin/bash ${SCRIPT_DIR}/prepare_start.sh

VOLUME ${CONF_DIR} \
  ${LOG_DIR}

EXPOSE 443 80

CMD ["/data/scripts/start.sh"]
