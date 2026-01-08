#!/bin/bash
set -e

source ~/.bash_profile

bash -c "cd /usr; mysqld --datadir='/var/lib/mysql' --user=mysql &"

sleep 1
until mysqladmin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done
service memcached start

mysql -e "create database mt_test character set utf8;"
mysql -e "create user mt@localhost;"
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

if [ -f t/cpanfile ]; then
    cpanm --installdeps -n . --cpanfile=t/cpanfile
fi

exec "$@"
