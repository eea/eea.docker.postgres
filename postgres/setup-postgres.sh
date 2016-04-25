#!/bin/bash
set -e

## Also include /postgresql.conf.d/*.conf
##
if [ -z "$POSTGRES_REPLICATE_FROM" ]; then
  echo "Updating $PGDATA/postgresql.conf"
  sed -ri "s/conf.d/\/postgresql.conf.d/g" $PGDATA/postgresql.conf
  sed -ri "s/#include_dir/include_dir/g" $PGDATA/postgresql.conf

  ## Create custom config file based on ENVIRONMENT variables
  ##
  setup-env.py
fi
