#!/bin/bash
set -e

find /var/lib/mysql -type f | xargs touch
service mysql start
service memcached start

if [ -f t/cpanfile ]; then
    cpm install -g --test --cpanfile=t/cpanfile
fi

exec "$@"
