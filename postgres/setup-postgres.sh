#!/bin/bash
set -x

## Also include /postgresql.conf.d/*.conf
##
echo "Updating $PGDATA/postgresql.conf"
sed -ri "s/conf.d/\/postgresql.conf.d/g" $PGDATA/postgresql.conf
sed -ri "s/#include_dir/include_dir/g" $PGDATA/postgresql.conf

## Create custom config file based on ENVIRONMENT variables
##
setup-env.py
