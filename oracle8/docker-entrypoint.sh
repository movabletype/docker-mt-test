#!/bin/bash
set -e

mysql_install_db --user=mysql --skip-name-resolve --force >/dev/null

bash -c "cd /usr; mysqld_safe --user=mysql --datadir=/var/lib/mysql &"
sleep 1
until mysqladmin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done

mysql -e "create database mt_test character set utf8;"
mysql -e "create user mt@localhost;"
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

memcached -d -u root

if [ -f t/cpanfile ]; then
    cpanm --installdeps -n . --cpanfile=t/cpanfile
fi

export MT_TEST_BACKEND=Oracle
export NLS_LANG=Japanese_Japan.AL32UTF8
export NLS_SORT=JAPANESE_M_CI

exec "$@"
