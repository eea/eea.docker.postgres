#!/bin/bash
set -e

/bin/setup-env.py
/bin/crond.sh

if [ -z "$POSTGRES_REPLICATE_FROM" ]; then
	exec /master-entrypoint.sh "$@"
else
	exec /replica-entrypoint.sh "$@"
fi
