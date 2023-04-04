#!/bin/bash
set -e

echo "Running setup-postgres ( include /postgresql.conf.d/*.conf)" 

## Also include /postgresql.conf.d/*.conf
##
ALREADY_FIXED=$( grep postgresql.conf.d $PGDATA/postgresql.conf || true )
if [ -z "$ALREADY_FIXED" ]; then
  echo "Updating $PGDATA/postgresql.conf"
  sed -ri "s|#include_dir =.*|include_dir = '/postgresql.conf.d'|g" $PGDATA/postgresql.conf
fi
