#!/bin/bash
set -e

service mysqld start
service memcached start

mysql -e "create database mt_test character set utf8;"
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

if [ -f t/cpanfile ]; then
    cpanm --installdeps ./t
fi

exec "$@"

