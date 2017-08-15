#!/bin/bash

set -e

for env_name in "SERVER_USER" "SERVER_GROUP"; do
  if [ -z ${!env_name} ]; then
    echo "Env ${env_name} must be set"
  fi
done

echo "Create user: ${SERVER_USER} and group: ${SERVER_GROUP}"
addgroup -S ${SERVER_GROUP}
adduser -D -S -h /var/cache/${SERVER_USER} -s /sbin/nologin -G ${SERVER_GROUP} ${SERVER_USER}

mkdir -p ${WWW_ROOT}

echo "<h1>hello world</h1>" > ${WWW_ROOT}/index.html
echo "<?php phpinfo();" > ${WWW_ROOT}/index.php

chown -R ${SERVER_USER}:${SERVER_GROUP} ${WWW_ROOT}
chmod +x ${SCRIPT_DIR}/start.sh
