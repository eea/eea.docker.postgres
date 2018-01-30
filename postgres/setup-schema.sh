#!/bin/bash
set -x

INITDB="yes"

if [ -z "$POSTGRES_DBNAME" ]; then
  INITDB=""
fi

if [ -z "$POSTGRES_DBUSER" ]; then
  INITDB=""
fi

if [ -z "$POSTGRES_DBPASS" ]; then
  INITDB=""
fi

if [ ! -z "$POSTGRES_REPLICATE_FROM" ]; then
  INITDB=""
fi

if [ ! -z "$INITDB" ]; then

  psql -q <<-EOF
CREATE USER $POSTGRES_DBUSER WITH PASSWORD '$POSTGRES_DBPASS';
EOF

  for db in $POSTGRES_DBNAME; do
    createdb -O $POSTGRES_DBUSER $POSTGRES_DBPARAMS $db
  done
fi
