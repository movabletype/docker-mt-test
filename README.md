# docker-mt-test
Dockerfile to test MT.

## Docker Hub

[movabletype/test](https://hub.docker.com/r/movabletype/test)

## Environment list (for CI)

|image name|base image|Perl|PHP|MySQL|OpenSSL|End of Life|
|-|-|-|-|-|-|-|
|centos7|centos:7|5.16.3|*7.3.33*|*MariaDB 5.5.68*|1.0.2k|2024-06|
|bullseye|debian:bullseye-slim|*5.32.1*|*7.4.33*|*MariaDB 10.5.29*|1.1.1w|2024-08|
|fedora35|fedora:35|*5.34.1*|*8.0.26*|8.0.31|1.1.1q|2022-12|
|fedora37|fedora:37|*5.36.1*|*8.1.25*|*8.0.35*|3.0.9|2023-12|
|fedora40|fedora:40|*5.38.4*|*8.2.30*|*MariaDB 10.11.11*|3.2.4|-|
|fedora42|fedora:42|*5.40.3*|*8.4.16*|*9.5.0*|3.2.6|-|
|fedora43|fedora:43|*5.42.0*|8.4.16|*8.4.7*|3.5.4|-|
|cloud7 (\*1)|rockylinux/rockylinux:9.6|*5.38.2*|*8.3.30*|MariaDB 10.5.29|3.5.1|-|

\*1 This image is not used in the MT cloud, but the well-known modules should have the same versions (except for those used only in tests).

## Environment list (multi platforms, suitable for mt-dev)

|image name|base image|Perl|PHP|MySQL|OpenSSL|End of Life|
|-|-|-|-|-|-|-|
|noble|ubuntu:noble|5.38.2|8.3.6|8.4.7|3.0.13|-|
|plucky|ubuntu:plucky|5.40.1|8.4.5|8.4.7|3.4.1|-|
|questing|ubuntu:questing|5.42.0|8.4.16|8.4.7|3.5.3|-|

## Environment list (only for manual testing)

|image name|base image|Perl|PHP|MySQL|OpenSSL|End of Life|
|-|-|-|-|-|-|-|
|buster (\*2)|debian:buster-slim|*5.28.1*|*7.3.31*|*MariaDB 10.3.39*|1.1.1n|2022-01|
|centos6 (\*2)|centos:6|*5.10.1*|*5.3.3*|*5.1.73*|1.0.1e|2020-11|
|fedora39 (\*2)|fedora:39|5.38.2|8.2.25|8.0.39|3.1.4|2024-11|
|fedora41 (\*2)|fedora:41|5.40.3|8.3.27|8.4.7|3.2.6|-|
|rawhide|fedora:rawhide|5.42.0|8.5.2|8.4.7|3.5.4|-|
|rockylinux|rockylinux/rockylinux:9.6|5.32.1|8.1.34|8.0.44|3.5.1|-|
|bookworm|debian:bookworm-slim|5.36.0|8.2.29|MariaDB 10.11.14|3.0.17|2028-06|
|sid|debian:sid|5.40.1|8.4.16|MariaDB 11.8.5|3.5.4|-|
|amazonlinux2023|amazonlinux:2023|5.32.1|8.4.14|MariaDB 10.11.13|3.2.2|-|
|postgresql|fedora:41|5.40.3|8.3.27|Postgres 16.11|3.2.6|-|
|oracle (\*3)|oraclelinux:9-slim|5.32.1|8.3.29|MariaDB 10.5.29|3.5.1|-|
|oracle8 (\*3)|oraclelinux:8-slim|5.26.3|8.2.30|MariaDB 10.3.39|1.1.1k|-|

\*2 These images were used to test older versions of MT.
\*3 with DBD::Oracle 1.80 + OracleInstantClient 26

## Special images

|image name|base image|extra packages|
|-|-|-|
|addons8|movabletype/test:cloud7|vsftpd 3.0.5, proftpd 1.3.8b, pureftpd 1.0.50, slapd 2.6.8|
|chromiumdriver|movabletype/test:bullseye|chromedriver 120.0.6099.224|
|playwright|movabletype/test:bookworm|node 24.12.0, playwright 1.57.0|

## How to update

```
$ perl bin/update_dockerfile.pl
$ perl bin/build_all.pl (with or without --no-cache)
$ perl bin/check_all.pl
$ perl bin/test_workflows.pl
$ perl bin/test_readme.pl
$ perl bin/build_all.pl --push

then, make a pull request, review, and merge it to mirror the uploaded images.
```

## Multi-platform build

See https://docs.docker.com/build/building/multi-platform/ for details.
If you do not use Docker Build Cloud, then prepare a remote environment with
a different architecture from your local environment. You'll need to add your
remote USER to the docker group and make sure remote dockerd is running.
Create your builder. The following uses local amd64 and remote arm64, but
you may do differently.

```
$ docker buildx create --name my_builder --node amd64 --platform linux/amd64
$ docker buildx create --name my_builder --append --node arm64 --platform linux/arm64 ssh://USER@HOST
```

Then specify your builder to build. Only a few images support multi-platform build right now.

```
$ perl bin/build_all.pl --builder my_builder
$ perl bin/build_all.pl --builder my_builder --push

push_all.pl doesn't work well for multi-platform images.
```
