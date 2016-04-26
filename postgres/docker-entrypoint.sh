#!/bin/bash
set -e

/bin/setup-env.py

if [ -z "$POSTGRES_REPLICATE_FROM" ]; then
	exec /master-entrypoint.sh "$@"
else
	exec /replica-entrypoint.sh "$@"
fi
