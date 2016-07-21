#!/bin/bash
set -e

/bin/crond.sh

if [ -z "$POSTGRES_REPLICATE_FROM" ]; then
	/bin/setup-env.py
	exec /master-entrypoint.sh "$@"
else
	exec /replica-entrypoint.sh "$@"
fi
