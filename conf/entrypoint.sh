#!/bin/bash
set -e

cron -f &

if [ $1 == "horizon" ]; then
    supervisord --nodaemon --configuration /etc/supervisord-horizon.conf

    exec "${@:2}"
else
    exec "$@"
fi
