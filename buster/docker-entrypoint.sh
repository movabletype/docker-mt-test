#!/bin/bash
set -e

chown -R mysql:mysql /var/lib/mysql
service mysql start
service memcached start

mysql -e "create database mt_test character set utf8;"
mysql -e "create user mt@localhost;"
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

if [ -f t/cpanfile ]; then
    cpanm --installdeps -n . --cpanfile=t/cpanfile
fi

exec "$@"
