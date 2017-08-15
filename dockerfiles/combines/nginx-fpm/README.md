## 概要

本项目用于build一个web-server容器，提供nginx + php-fpm 服务。支持自定义nginx vhost配置，php.ini配置以及php-fpm.conf配置

## 版本

| Docker Tag | Github Release | Nginx Version | PHP Version | Alpine Version |
| --- | --- | --- | --- | --- |
| latest | Master Branch | build时指定 | 7.1.8 | 3.6 |

## 快速开始

#### pull

```shell
$ sudo docker pull leikouscu/nginx-fpm:latest
```

#### Running

```shell
sudo docker run -d -p host_port:80 -p host_port:443 leikouscu/nginx-fpm:latest
```

现在你可以在宿主机上访问http://localhost:host_port，如果一切正常，会输出

```shell
hello world
```

如果要验证php正常运行，可以在宿主机上访问http://localhost:host_port/index.php

## 文档

#### nginx & fpm worker user

nginx 与 fpm worker 以用户 www 运行，该用户可以在image build阶段指定

#### www 根目录

/var/www

#### Volume

* 1. 配置挂载点

image指定/data/conf为配置挂载点，用于挂载自定义配置文件，默认情况下，在运行时，会检查如下配置文件是否存在，如果存在则复制到对应的地址

| 配置文件 | 复制地址 |
| --- | --- |
| /data/conf/server/nginx-site.conf | /usr/local/nginx/conf/conf.d/nginx-site.conf |
| /data/conf/server/php.ini | /usr/local/etc/php/conf.d/docker-vars.ini |
| /data/conf/server/fpm.conf | /user/loca/etc/php-fpm.d/www.conf |

image会检查环境变量: PROJECT_CONF_SCRIPT，如果被设置，且为一个普通文件，则执行该文件。因此我们可以在构建项目特定image时，设置项目配置的处理逻辑

***注意***: 自定义配置文件的处理只会在第一次容器运行时才会执行，重新运行已有的容器并不会处理自定义配置文件。(这样做的目的是为了创建immutable service)

* 2. 日志挂载点

image指定/usr/local/var/log 为日志挂载点，所有日志会写入本目录

| 相对路经 | 描述 |
| --- | --- |
| ${HOSTNAME}.fpm.log | fpm 运行错误日志 |
| ${HOSTNAME}.nginx_access.log | nginx 访问日志 |
| ${HOSTNAME}.nginx_error.log | nginx 错误日志 |
