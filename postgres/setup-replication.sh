#!/bin/sh
set -e

if [ ! -z "$POSTGRES_REPLICATE_FROM" ]; then

cat > ${PGDATA}/recovery.conf <<EOF
standby_mode = on
primary_conninfo = 'host=$POSTGRES_REPLICATE_FROM port=5432 user=$POSTGRES_USER'
trigger_file = '/tmp/touch_me_to_promote_to_me_master'
EOF

chown postgres ${PGDATA}/recovery.conf
chmod 600 ${PGDATA}/recovery.conf

fi
