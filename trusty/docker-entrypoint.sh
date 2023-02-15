#!/bin/bash
set -e

find /var/lib/mysql -type f | xargs touch
service mysql start
service memcached start

mysql -e "create database mt_test character set utf8;"
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

if [ -f t/cpanfile ]; then
    cpm install --show-build-log-on-failure -g --cpanfile=t/cpanfile
fi

exec "$@"
