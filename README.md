# docker-mt-test
Dockerfile to test MT.

## Docker Hub

[movabletype/test](https://hub.docker.com/r/movabletype/test)

## Environment list (for CI)

|image name|base image|Perl|PHP|MySQL|OpenSSL|End of Life|
|-|-|-|-|-|-|-|
|centos7|centos:7|5.16.3|*7.1.33*|*MariaDB 5.5.68*|1.0.2k|2024-06|
|buster|debian:buster-slim|*5.28.1*|*7.3.31*|*MariaDB 10.3.39*|1.1.1n|2022-01|
|bullseye|debian:bullseye-slim|*5.32.1*|*7.4.33*|*MariaDB 10.5.28*|1.1.1w|2024-08|
|fedora35|fedora:35|*5.34.1*|8.0.26|8.0.31|1.1.1q|2022-12|
|fedora37|fedora:37|*5.36.1*|*8.1.25*|8.0.35|3.0.9|2023-12|
|fedora39|fedora:39|*5.38.2|*8.2.25*|*8.0.39*|3.1.4|2024-11|
|fedora41|fedora:41|5.40.2|*8.3.21*|8.4.5|3.2.4|-|
|fedora42|fedora:42|*5.40.2*|*8.4.7*|*9.3.0*|3.2.4|-|
|cloud6 (\*1)|centos:7|*5.28.2*|*7.4.33*|*5.7.44*|1.0.2k|-|
|cloud7 (\*1)|rockylinux/rockylinux:9|5.38.2|8.2.28|MariaDB 10.5.27|3.2.2|-|

\*1 These images are not used in the MT cloud, but the well-known modules should have the same version (except for those used only in tests).

## Environment list (only for manual testing)

|image name|base image|Perl|PHP|MySQL|OpenSSL|End of Life|
|-|-|-|-|-|-|-|
|centos6 (\*2)|centos:6|*5.10.1*|*5.3.3*|*5.1.73*|1.0.1e|2020-11|
|centos8|centos:8|5.26.3|8.0.30|8.0.26|1.1.1k|2021-12|
|fedora32 (\*2)|fedora:32|*5.30.3*|7.4.19|8.0.24|1.1.1k|2021-05|
|fedora40 (\*2)|fedora:40|5.38.4|8.3.20|8.0.41|3.2.4|-|
|rawhide|fedora:rawhide|5.40.2|8.4.7|8.4.5|3.5.0|-|
|rockylinux|rockylinux/rockylinux:9|5.32.1|8.1.32|8.0.41|3.2.2|-|
|bookworm|debian:bookworm-slim|5.36.0|8.2.28|*MariaDB 10.11.11*|3.0.15|2028-06|
|sid|debian:sid|5.40.1|8.4.6|MariaDB 11.8.1|3.5.0|-|
|noble|ubuntu:noble|5.38.2|8.3.6|8.4.5|3.0.13|-|
|amazonlinux|amazonlinux:2|5.16.3|7.4.33|MariaDB 5.5.68|1.0.2k|-|
|amazonlinux2022 (\*4)|amazonlinux:2023|5.32.1|8.3.7|MariaDB 10.5.25|3.0.8|-|
|postgresql|fedora:41|5.40.2|8.3.21|Postgres 16.8|3.2.4|-|
|oracle (\*3)|oraclelinux:7-slim|5.16.3|7.4.33|MariaDB 5.5.68|1.0.2k|-|
|oracle8 (\*3)|oraclelinux:8-slim|5.26.3|8.2.28|MariaDB 10.3.39|1.1.1k|-|

\*2 These images were used to test older versions of MT.
\*3 with DBD::Oracle 1.80 + OracleInstantClient 21.7
\*4 This image currently lacks php-dom, thus phpunit

## Special images

|image name|base image|extra packages|
|-|-|-|
|addons8|movabletype/test:cloud7|vsftpd 3.0.5, proftpd 1.3.8b, pureftpd 1.0.50, slapd 2.6.6|
|chromiumdriver|movabletype/test:bullseye|chromedriver 120.0.6099.224|
|playwright|movabletype/test:bullseye|node 22.15.1, playwright 1.52.0|

## How to update

```
$ perl bin/update_dockerfile.pl
$ perl bin/build_all.pl (with or without --no-cache)
$ perl bin/check_all.pl
$ perl bin/test_readme.pl
$ perl bin/push_all.pl

then, make a pull request, review, and merge it to mirror the uploaded images.
```
