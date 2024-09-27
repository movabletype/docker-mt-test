#!/bin/bash
set -e

service memcached start

if [ -f t/cpanfile ]; then
    cpanm --installdeps -n . --cpanfile=t/cpanfile
fi

exec "$@"
