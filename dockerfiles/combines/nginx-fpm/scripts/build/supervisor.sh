#!/bin/bash

apk add supervisor
SUPERVISOR_CONF_DIR=/etc/supervisor.d
mkdir -p ${SUPERVISOR_CONF_DIR}
cp -f ${BUILD_DIR}/conf/supervisor* ${SUPERVISOR_CONF_DIR}/
