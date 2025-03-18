#!/bin/bash
set -e

echo 'default_authentication_plugin = mysql_native_password' >> /etc/my.cnf.d/mariadb-server.cnf
mysql_install_db --user=mysql --skip-name-resolve --force >/dev/null

bash -c "cd /usr; mysqld_safe --datadir=/var/lib/mysql --user=mysql &"

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


exec "$@"
