#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
	set -- postgres "$@"
fi

if [ "$1" = 'postgres' ]; then
	/bin/setup-env.py
	mkdir -p "$PGDATA"
	chmod 700 "$PGDATA"
	chown -R postgres "$PGDATA"

	chmod g+s /run/postgresql
	chown -R postgres /run/postgresql

	# look specifically for PG_VERSION, as it is expected in the DB dir
	if [ ! -s "$PGDATA/PG_VERSION" ]; then

		until ping -c 1 -W 1 master
    do
        echo "Waiting for master to ping..."
        sleep 1s
    done
    until gosu postgres pg_basebackup -h master -D ${PGDATA} -U ${POSTGRES_USER} -vP
    do
        echo "Waiting for master to connect..."
        sleep 1s
    done
    chmod 700 ${PGDATA}

		echo
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

	exec gosu postgres "$@"
fi

exec "$@"
