#!/bin/bash
set -e

service mysqld start
service memcached start

if [ -f t/cpanfile ]; then
    cpanm --installdeps ./t
fi

exec "$@"

