# Usage:
# docker build --build-arg NGINX_VERSION=1.13.4 -t <name> .

# build nginx
FROM php:7.1.8-fpm-alpine AS nginx
ARG USER
ARG GROUP
ARG NGINX_VERSION
ENV NGINX_GROUP=${GROUP:-www} \
	NGINX_USER=${USER:-www} \
  NGINX_VERSION=${NGINX_VERSION}
WORKDIR /build
COPY scripts/bash_install.sh .
COPY scripts/nginx_build.sh .
RUN /bin/sh bash_install.sh \
  && /bin/bash nginx_build.sh

# run server
FROM php:7.1.8-fpm-alpine
ARG USER
ARG GROUP
ENV SERVER_GROUP=${GROUP:-www} \
  SERVER_USER=${USER:-www} \
  SCRIPT_DIR=/root/scripts
LABEL author=leikou \
      email=leikouscu@gmail.com
COPY --from=nginx /usr/local/nginx /usr/local/nginx/
COPY scripts/bash_install.sh ${SCRIPT_DIR}/
COPY scripts/prepare_start.sh ${SCRIPT_DIR}/
RUN /bin/sh ${SCRIPT_DIR}/bash_install.sh \
  && /bin/bash ${SCRIPT_DIR}/prepare_start.sh
