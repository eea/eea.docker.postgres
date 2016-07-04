#!/bin/bash
set -e

DB=$1

if [ -z "${DB}" ]; then
  echo "Usage gosu postgres /postgres.restore/database-backup.sh mydb"
  exit 1
fi

pg_dump ${DB} | gzip > /postgresql.backup/${DB}.gz
