# docker-mt-test
Dockerfile to test MT.

## Docker Hub

[movabletype/test](https://hub.docker.com/r/movabletype/test)

## Environment list (for CI)

|image name|base image|Perl|PHP|MySQL|End of Life|
|-|-|-|-|-|-|
|centos6|centos:6|*5.10.1*|*5.3.3*|*5.1.73*|2020-11|
|jessie|debian:jessie|5.20.2|*5.6.40*|*5.5.62*|2020-06 (LTS)|
|buster|debian:buster|*5.28.1*|*7.3.11-1*|*MariaDB 10.3.22*|2022-01|
|fedora|fedora:31|*5.30.1*|7.3.14|*8.0.19*|-|

## Environment list (only for manual testing)

|image name|base image|Perl|PHP|MySQL|End of Life|
|-|-|-|-|-|-|
|centos7|centos:7|5.16.3|*5.4.16*|*MariaDB 5.5.64*|2024-06|
|centos8|centos:8|5.26.3|*7.2.11*|8.0.17|2029-03|
|fedora23|fedora:23|5.22.2|5.6.29|*5.6.33*|2016-12|
|trusty|ubuntu:trusty|5.18.2|*5.5.9*|5.5.58|2019-04|
|stretch|debian:stretch|5.24.1|*7.0.19-1*|*MariaDB 10.1.26*|2022-01 (LTS)|
|bionic|ubuntu:bionic|5.26.1|7.2.3|*5.7.12*|2023-04|
|amazonlinux|amazonlinux:2|5.16.3|5.4.16|MariaDB 5.5.64|-|

## Special images

|image name|base image|extra packages|
|-|-|-|
|addons|movabletype/test:buster|vsftpd 3.0.3-12|
|chromedriver|debian:buster|chromium-driver 79.0.3945.130-1~deb10u1|
|openldap|centos:6|openldap 2.4.40|
