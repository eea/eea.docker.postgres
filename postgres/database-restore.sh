#!/bin/bash
set -e

DB=$1
USER=${POSTGRES_DBUSER:-zope}

if [ -z "$DB" ]; then
  echo "Usage gosu postgres /postgres.restore/database-restore.sh mydb"
  exit 1
fi

if [ ! -f /postgresql.backup/$DB.gz ]; then
  echo "Please provide restoring pg_dump at /postgresql.backup/$DB.gz"
  exit 1
fi

psql -q <<-EOF
  update pg_database set datallowconn = 'false' where datname = '$DB';
  SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB';
  DROP DATABASE $DB;
  CREATE DATABASE $DB WITH OWNER=$USER CONNECTION LIMIT=0;
EOF

# Re-import database from gzip
bash -c "gunzip -c /postgresql.backup/$DB.gz | psql $DB"

# Allow connections to database
psql -q <<-EOF
  ALTER DATABASE $DB WITH CONNECTION LIMIT=-1;
EOF
