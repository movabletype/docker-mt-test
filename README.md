# docker-mt-test
Dockerfile to test MT.

## Docker Hub

[movabletype/test](https://hub.docker.com/r/movabletype/test)

## Environment list (for CI)

|image name|base image|Perl|PHP|MySQL|OpenSSL|End of Life|
|-|-|-|-|-|-|-|
|centos6|centos:6|*5.10.1*|*5.5.38*|*5.1.73*|1.0.1e|2020-11|
|jessie|debian:jessie|5.20.2|*5.6.40*|*5.5.62*|1.0.1t|2020-06 (LTS)|
|buster|debian:buster|*5.28.1*|*7.3.31*|*MariaDB 10.3.34*|1.1.1n|2022-01|
|fedora35|fedora:35|*5.34.1*|*8.0.20*|*8.0.28*|1.1.1o|-|
|bullseye|debian:bullseye|*5.32.1*|*7.4.28*|*MariaDB 10.5.15*|1.1.1n|-|
|cloud6 (\*1)|centos:7|*5.28.2*|*7.4.30*|*5.7.38*|1.0.2k|-|
|cloud7 (\*1)|centos:7|*5.28.2*|*7.4.30*|*5.7.38*|1.0.2k|-|

\*1 These images are not used in the MT cloud, but the well-known modules should have the same version (except for those used only in tests).

## Environment list (only for manual testing)

|image name|base image|Perl|PHP|MySQL|OpenSSL|End of Life|
|-|-|-|-|-|-|-|
|centos7|centos:7|5.16.3|*7.1.33*|*MariaDB 5.5.68*|1.0.2k|2024-06|
|centos8|centos:8|5.26.3|*8.0.20*|8.0.26|1.1.1k|2021-12|
|fedora23|fedora:23|5.22.2|5.6.29|*5.6.33*|1.0.2j|2016-12|
|fedora32|fedora:32|*5.30.3*|7.4.19|8.0.24|1.1.1k|-|
|trusty|ubuntu:trusty|5.18.2|5.5.9|5.5.62|1.0.1f|2019-04|
|stretch|debian:stretch|5.24.1|*7.0.33*|*MariaDB 10.1.48*|1.1.0l|2022-01 (LTS)|
|bionic|ubuntu:bionic|5.26.1|7.2.24|5.7.38|1.1.1|2023-04|
|sid|debian:sid|*5.34.0*|*8.1.5*|*MariaDB 10.6.8*|3.0.4|-|
|amazonlinux|amazonlinux:2|5.16.3|7.4.29|MariaDB 5.5.68|1.0.2k|-|
|amazonlinux2022 (\*4)|amazonlinux:2022|5.32.1|7.4.19|MariaDB 10.5.13|1.1.1l|-|
|oracle (\*2)|oraclelinux:7-slim|5.16.3|7.4.30|MariaDB 5.5.68|1.0.2k|-|
|oracle8 (\*3)(\*4)|oraclelinux:8-slim|5.26.3|7.4.19|MariaDB 10.3.32|1.1.1k|-|

\*2 with DBD::Oracle 1.80 + OracleInstantClient 19.6
\*3 with DBD::Oracle 1.80 + OracleInstantClient 21.5
\*4 These images currently lack php-dom, thus phpunit

## Special images

|image name|base image|extra packages|
|-|-|-|
|addons|movabletype/test:buster|vsftpd 3.0.3-12, proftpd 1.3.7a, pureftpd 1.0.49|
|chromedriver|fedora:32|chromium-driver 85.0.4183.121|
|chromiumdriver|movabletype/test:buster|chromium-driver 87.0.4280.141-0.1~deb10u1|
|openldap|centos:6|openldap 2.4.40|
