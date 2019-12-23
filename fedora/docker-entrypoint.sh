#!/bin/bash
set -e

mysqld --initialize-insecure --user=mysql --skip-name-resolve >/dev/null

bash -c "cd /usr; mysqld --datadir='/var/lib/mysql' --user=mysql &"

sleep 1
until mysqladmin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done

mysql -e "create database mt_test character set utf8;"
mysql -e "create user mt@localhost"
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

memcached -d -u root

if [ -f t/cpanfile ]; then
    cpm install -g --cpanfile=t/cpanfile
fi

exec "$@"

