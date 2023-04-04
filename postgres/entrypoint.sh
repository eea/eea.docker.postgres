#!/bin/bash
set -e

/bin/crond.sh

mkdir -p $PG_ARCHIVE $PG_CONFD $PG_RESTORE $PG_BACKUP
chown -R postgres:postgres $PG_ARCHIVE $PG_CONF $PG_RESTORE $PG_BACKUP

if [ -z "$POSTGRES_REPLICATE_FROM" ]; then
	/bin/setup-env.py
	exec master-entrypoint.sh "$@"
else
	exec replica-entrypoint.sh "$@"
fi
