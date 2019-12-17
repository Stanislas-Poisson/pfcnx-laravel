#!/bin/sh
set -e

cron -f &
exec "$@"
