# docker-mt-test
Dockerfile to test MT.

## Docker Hub

[movabletype/test](https://hub.docker.com/r/movabletype/test)

## Environment list (for CI)

|image name|base image|Perl|PHP|MySQL|OpenSSL|End of Life|
|-|-|-|-|-|-|-|
|centos7|centos:7|5.16.3|*7.1.33*|*MariaDB 5.5.68*|1.0.2k|2024-06|
|buster|debian:buster|*5.28.1*|*7.3.31*|*MariaDB 10.3.39*|1.1.1n|2022-01|
|bullseye|debian:bullseye|*5.32.1*|*7.4.33*|*MariaDB 10.5.26*|1.1.1w|-|
|fedora35|fedora:35|*5.34.1*|8.0.26|8.0.31|1.1.1q|-|
|fedora37|fedora:37|*5.36.1*|*8.1.25*|8.0.35|3.0.9|-|
|fedora39|fedora:39|5.38.2|*8.2.24*|8.0.39|3.1.4|-|
|fedora40|fedora:40|*5.38.2*|8.3.12|*8.0.39*|3.2.2|-|
|fedora41|fedora:41|*5.40.0*|*8.3.12*|*8.0.39*|3.2.2|-|
|cloud6 (\*1)|centos:7|*5.28.2*|*7.4.33*|*5.7.44*|1.0.2k|-|
|cloud7 (\*1)|rockylinux:9|5.38.2|8.2.24|MariaDB 10.5.22|3.0.7|-|

\*1 These images are not used in the MT cloud, but the well-known modules should have the same version (except for those used only in tests).

## Environment list (only for manual testing)

|image name|base image|Perl|PHP|MySQL|OpenSSL|End of Life|
|-|-|-|-|-|-|-|
|centos6 (\*2)|centos:6|*5.10.1*|*5.5.38*|*5.1.73*|1.0.1e|2020-11|
|centos8|centos:8|5.26.3|*8.0.30*|8.0.26|1.1.1k|2021-12|
|fedora32 (\*2)|fedora:32|*5.30.3*|7.4.19|8.0.24|1.1.1k|-|
|rawhide|fedora:rawhide|5.40.0|8.4.0|8.0.39|3.2.2|-|
|rockylinux|rockylinux:9|5.32.1|8.1.30|8.0.36|3.0.7|-|
|bookworm|debian:bookworm|5.36.0|8.2.24|*MariaDB 10.11.6*|3.0.14|-|
|sid|debian:sid|5.40.0|8.2.24|MariaDB 11.4.3|3.3.2|-|
|amazonlinux|amazonlinux:2|5.16.3|7.4.33|MariaDB 5.5.68|1.0.2k|-|
|amazonlinux2022 (\*4)|amazonlinux:2023|5.32.1|8.3.7|MariaDB 10.5.25|3.0.8|-|
|oracle8 (\*3)|oraclelinux:8|5.26.3|8.2.24|MariaDB 10.3.39|1.1.1k|-|

\*2 These images were used to test older versions of MT.
\*3 with DBD::Oracle 1.80 + OracleInstantClient 21.7
\*4 This image currently lacks php-dom, thus phpunit

## Special images

|image name|base image|extra packages|
|-|-|-|
|addons8|movabletype/test:cloud7|vsftpd 3.0.5, proftpd 1.3.8b, pureftpd 1.0.50, slapd 2.6.6|
|chromiumdriver|movabletype/test:bullseye|chromedriver 120.0.6099.224|
|playwright|movabletype/test:bullseye|node 20.18.0, playwright 1.48.1|
