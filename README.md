# docker-mt-test
Dockerfile to test MT.

## Docker Hub

[movabletype/test](https://hub.docker.com/r/movabletype/test)

## Environment list

|image name|base image|Perl|PHP|MySQL|Memcached|
|-|-|-|-|-|-|
|centos6|centos:6|5.10.1|5.3.3|5.1.73|1.4.4|
|centos7|centos:7|5.16.3|5.4.16|MariaDB 5.5.60|1.4.15|
|trusty|ubuntu:trusty|5.18.2|5.5.9|5.5.58|1.4.14|
|jessie|debian:jessie|5.20.2|5.6.40|5.5.62|1.4.21|
|stretch|debian:stretch|5.24.1|7.0.19-1|MariaDB 10.1.26|1.4.33|
|buster|debian:buster|5.28.1|7.3.9-1|MariaDB 10.3.17|1.5.6|
|bionic|ubuntu:bionic|5.26.1|7.2.3|5.7.12|1.5.6|
|disco|ubuntu:disco|5.28.1|7.2.11|5.7.26|1.5.10|
|fedora|fedora:31|5.30.0|7.3.9|MariaDB 10.3.17|1.5.16|

## Special images

|image name|base image|extra packages|
|-|-|-|
|addons|movabletype/test:buster|vsftpd 3.0.3-12|
|chromedriver|movabletype/test:buster|chromium-driver 76.0.3809.100-1|
|openldap|centos:6|openldap 2.4.40|
