#!/bin/bash
set -e

function setup_default_recovery {

cat > ${PGDATA}/recovery.conf <<EOF
standby_mode = on
primary_conninfo = 'host=$POSTGRES_REPLICATE_FROM port=5432 user=$POSTGRES_USER'
trigger_file = '/tmp/touch_me_to_promote_to_me_master'
EOF

}

# POSTGRES_REPLICATE_FROM env present
if [ ! -z "$POSTGRES_REPLICATE_FROM" ]; then
  # recovery.conf is not already in place
  if [ ! -f "${PGDATA}/recovery.conf" ]; then
    # This instance is still a replica (was not promoted to master)
    if [ ! -f "${PGDATA}/recovery.done" ]; then
      setup_default_recovery
    fi
  fi
fi

# Fix file permissions
if [ -f "${PGDATA}/recovery.conf" ]; then
  chown postgres ${PGDATA}/recovery.conf
  chmod 600 ${PGDATA}/recovery.conf
fi
