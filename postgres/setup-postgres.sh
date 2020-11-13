#!/bin/bash
set -e

## Also include /postgresql.conf.d/*.conf
##
ALREADY_FIXED=$( grep include_dir.*postgresql.conf.d $PGDATA/postgresql.conf || true )
if [ -z "$ALREADY_FIXED" ]; then
  echo "Updating $PGDATA/postgresql.conf"
  sed -i "s#include_dir = .*#include_dir = '/postgresql.conf.d'#g" $PGDATA/postgresql.conf
fi
