#!/bin/bash
set -e

service mysqld start
service memcached start

sed -i -E 's/inet_protocols = all/inet_protocols = ipv4/' /etc/postfix/main.cf

mysql -e "create database if not exists mt_test character set utf8;"
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

memcached -d -u root

if [ -f t/cpanfile ]; then
    cpanm --installdeps -n . --cpanfile=t/cpanfile
fi

exec "$@"
