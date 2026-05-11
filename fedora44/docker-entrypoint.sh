#!/bin/bash
set -e

mariadb-install-db --user=mysql --skip-name-resolve --force >/dev/null

bash -c "cd /usr; /usr/bin/mariadbd-safe --user=mysql --datadir=/var/lib/mysql &"
sleep 1
until /usr/bin/mariadb-admin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done

/usr/bin/mariadb -e "create database mt_test character set utf8;"
/usr/bin/mariadb -e "create user mt@localhost;"
/usr/bin/mariadb -e "grant all privileges on mt_test.* to mt@localhost;"

memcached -d -u root

if [ -f t/cpanfile ]; then
    cpanm --installdeps -n . --cpanfile=t/cpanfile
fi

exec "$@"
