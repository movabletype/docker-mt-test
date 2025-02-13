#!/bin/bash
set -e


export PGDATA=/var/lib/postgresql/data
install --verbose --directory --owner postgres --group postgres --mode 1777 /var/lib/postgresql
install --verbose --directory --owner postgres --group postgres --mode 3777 /var/run/postgresql

su -c 'initdb --show' postgres
su -c 'initdb -D /var/lib/postgresql/data' postgres

su -c 'pg_ctl -D /var/lib/postgresql/data start' postgres

su -c 'createuser mt' postgres
su -c 'createdb -O mt mt_test' postgres

memcached -d -u root

if [ -f t/cpanfile ]; then
    perl -i -nE 'print unless /(?:DBD::mysql|App::Prove::Plugin::MySQLPool)/' t/cpanfile &&\
    cpanm --installdeps -n . --cpanfile=t/cpanfile
fi

export MT_TEST_BACKEND=Pg

exec "$@"
