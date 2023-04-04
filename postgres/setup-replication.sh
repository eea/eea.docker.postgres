#!/bin/bash
set -e

echo "Running setup replication"

function setup_default_recovery {
touch /var/lib/postgresql/data/standby.signal
cat > /postgresql.conf.d/zenvreplica.conf <<EOF
primary_conninfo = 'host=$POSTGRES_REPLICATE_FROM port=5432 user=$POSTGRES_USER'
promote_trigger_file = '/tmp/touch_me_to_promote_to_me_master'
EOF

}

# POSTGRES_REPLICATE_FROM env present
if [ ! -z "$POSTGRES_REPLICATE_FROM" ]; then
  if [ ! -f /var/lib/postgresql/data/standby.signal ]; then
    # This instance is still a replica (was not promoted to master)
    if [ ! -f "/tmp/touch_me_to_promote_to_me_master" ]; then
      setup_default_recovery
    fi
  fi
fi

