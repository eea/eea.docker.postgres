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

if [ ! -z "$INITDB" ]; then

echo "****** CREATING $POSTGRES_DBNAME DATABASE ******"

gosu postgres postgres --single <<- EOSQL
CREATE USER $POSTGRES_DBUSER WITH PASSWORD '$POSTGRES_DBPASS';
CREATE DATABASE $POSTGRES_DBNAME WITH OWNER $POSTGRES_DBUSER;
EOSQL

echo ""
echo "****** DATABASE $POSTGRES_DBNAME CREATED ******"

fi
