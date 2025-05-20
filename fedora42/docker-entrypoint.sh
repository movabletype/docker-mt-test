#!/bin/bash
set -e

echo 'default_authentication_plugin = mysql_native_password' >> /etc/my.cnf.d/mysql-server.cnf
mysqld --initialize-insecure --user=mysql --skip-name-resolve >/dev/null

bash -c "cd /usr; mysqld --datadir='/var/lib/mysql' --user=mysql &"

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
    perl -i -nE 'print unless /(?:YAML::Syck)/' t/cpanfile &&\
    cpanm --installdeps -n . --cpanfile=t/cpanfile
fi


exec "$@"
