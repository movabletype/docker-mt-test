#!/bin/bash
set -e

memcached -u root&

mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql --auth-root-authentication-method=normal --skip-name-resolve --force >/dev/null

bash -c "cd /usr; mysqld --datadir='/var/lib/mysql' --user=mysql &"

sleep 1
until mysqladmin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done

mysql -e "create database mt_test character set utf8;"
mysql -e "create user mt@localhost;"
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

PATH=$PATH:/usr/bin/site_perl:/usr/bin/core_perl

cat <<PHP >> /etc/php/conf.d/mt.ini
extension=gd
extension=mysqli
extension=pdo_mysql
PHP

if [ -f t/cpanfile ]; then
    cpm install -g --cpanfile=t/cpanfile
fi

exec "$@"
