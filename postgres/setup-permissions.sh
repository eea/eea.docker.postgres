#!/bin/bash
# Restrict replication only on POSTGRES_REPLICATION_NETWORK
# e.g.:
#   POSTGRES_REPLICATION_NETWORK="172.16.0.0/12"
#
if [ ! -z "$POSTGRES_REPLICATION_NETWORK" ]; then
  ALREADY_FIXED=$( grep "$POSTGRES_REPLICATION_NETWORK" /var/lib/postgresql/data/pg_hba.conf || true )
  if [ -z "$ALREADY_FIXED" ]; then
    echo "host replication all $POSTGRES_REPLICATION_NETWORK trust" >> /var/lib/postgresql/data/pg_hba.conf
  fi
else
    # Docker network
    echo "host replication all 172.16.0.0/12 trust" >> /var/lib/postgresql/data/pg_hba.conf

    # Rancher network
    echo "host replication all 10.0.0.0/8 trust" >> /var/lib/postgresql/data/pg_hba.conf
fi