#!/bin/bash

# Docker network
echo "host replication all 172.17.0.0/16 trust" >> /var/lib/postgresql/data/pg_hba.conf

# Rancher network
echo "host replication all 10.42.0.0/16 trust" >> /var/lib/postgresql/data/pg_hba.conf
