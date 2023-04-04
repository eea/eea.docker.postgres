#!/bin/bash
set -e

/bin/crond.sh

mkdir -p $PG_ARCHIVE $PG_CONFD $PG_RESTORE $PG_BACKUP
chown -R postgres:postgres $PG_ARCHIVE $PG_CONF $PG_RESTORE $PG_BACKUP

if [ -z "$POSTGRES_REPLICATE_FROM" ]; then
	/bin/setup-env.py
else
     if [ "$1" = 'postgres' ]; then
        mkdir -p "$PGDATA"
        chmod 700 "$PGDATA"
        chown -R postgres "$PGDATA"

        chmod g+s /run/postgresql
        chown -R postgres /run/postgresql

        # look specifically for PG_VERSION, as it is expected in the DB dir
        if [ ! -s "$PGDATA/PG_VERSION" ]; then
                until ping -c 1 -W 1 $POSTGRES_REPLICATE_FROM
                do
                        echo "Waiting for master ($POSTGRES_REPLICATE_FROM) to ping..."
                        sleep 1s
                done
                until gosu postgres pg_basebackup -h $POSTGRES_REPLICATE_FROM -D ${PGDATA} -U ${POSTGRES_USER} -vP
                do
                        echo "Waiting for master ($POSTGRES_REPLICATE_FROM) to connect..."
                        sleep 1s
                done
                chmod 700 ${PGDATA}
                echo
                
		/bin/setup-env.py
		for f in /docker-entrypoint-initdb.d/*; do
			case "$f" in
				*.sh)     echo "$0: running $f"; . "$f" ;;
				*.sql)    echo "$0: running $f"; "${psql[@]}" < "$f"; echo ;;
				*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${psql[@]}"; echo ;;
				*)        echo "$0: ignoring $f" ;;
			esac
			echo
		done

        fi
     fi
fi

exec docker-entrypoint.sh "$@"
