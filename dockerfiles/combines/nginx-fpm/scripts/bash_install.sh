#!/bin/sh

cp /etc/apk/repositories /etc/apk/repositories.bak
echo "https://mirrors.aliyun.com/alpine/v3.6/main" > /etc/apk/repositories

apk update
apk add bash
