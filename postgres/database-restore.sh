#!/bin/bash
set -e

USER=${POSTGRES_DBUSER:-zope}
DB=$1
GZ=$2

if [ -z "${GZ}" ]; then
    GZ="/postgresql.backup/${DB}.gz"
fi

if [ -z "${DB}" ]; then
  echo "Usage gosu postgres /postgres.restore/database-restore.sh mydb [/path/to/mydb.gz]"
  exit 1
fi

if [ ! -f ${GZ} ]; then
  echo "Please provide restoring pg_dump at ${GZ}"
  exit 1
fi

psql -q <<-EOF
  DROP DATABASE IF EXISTS ${DB}_tmp;
  CREATE DATABASE ${DB}_tmp WITH OWNER=${USER} CONNECTION LIMIT=0;
EOF

# Re-import database from gzip
bash -c "gunzip -c ${GZ} | psql ${DB}_tmp"

# Allow connections to database
psql -q <<-EOF
  update pg_database set datallowconn = 'false' where datname = '${DB}';
  SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${DB}';
  DROP DATABASE IF EXISTS ${DB};
  ALTER DATABASE ${DB}_tmp RENAME TO ${DB};
  ALTER DATABASE ${DB} WITH CONNECTION LIMIT=-1;
EOF
