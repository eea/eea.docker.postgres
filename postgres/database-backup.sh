#!/bin/bash
set -e

DB=$1
GZ=$2

if [ -z "${GZ}" ]; then
    GZ="/postgresql.backup/${DB}.gz"
fi

if [ -z "${DB}" ]; then
  echo "Usage gosu postgres /postgres.restore/database-backup.sh mydb [/path/to/mydb.gz]"
  exit 1
fi

pg_dump ${DB} | gzip > ${GZ}
