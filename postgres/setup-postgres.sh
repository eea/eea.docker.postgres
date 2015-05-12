#!/bin/bash
set -x

echo "Updating $PGDATA/postgresql.conf"
sed -ri "s/conf.d/\/postgresql.conf.d/g" $PGDATA/postgresql.conf
sed -ri "s/#include_dir/include_dir/g" $PGDATA/postgresql.conf
