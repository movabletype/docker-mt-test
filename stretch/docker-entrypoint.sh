#!/bin/bash
set -e

service mysql start
service memcached start

if [ -f t/cpanfile ]; then
    cpm install -g --test --cpanfile=t/cpanfile
fi

exec "$@"

