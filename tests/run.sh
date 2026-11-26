#!/usr/bin/env bash
#
# Functional tests for the eeacms/postgres image.
#
# Usage:
#   tests/run.sh <image> [expected-major-version]
#
# Examples:
#   docker build -t eeacms/postgres:test postgres/
#   tests/run.sh eeacms/postgres:test 14
#
# The script starts throw-away containers on a dedicated docker network,
# checks that the database starts and that configuration coming from
# environment variables is applied, then removes everything it created.
# Exit code is 0 only if every check passed.

set -uo pipefail

IMAGE="${1:-}"
EXPECTED_MAJOR="${2:-}"
TIMEOUT="${TEST_TIMEOUT:-120}"

if [ -z "$IMAGE" ]; then
  echo "Usage: $0 <image> [expected-major-version]" >&2
  exit 2
fi

PREFIX="pgtest-$$"
NET="$PREFIX-net"
MAIN="$PREFIX-main"
MASTER="$PREFIX-master"
REPLICA="$PREFIX-replica"

PASSED=0
FAILED=0
FAILURES=()

# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------

cleanup() {
  for c in "$MAIN" "$MASTER" "$REPLICA"; do
    if [ "${KEEP_CONTAINERS:-}" = "1" ] && [ "$FAILED" -gt 0 ]; then
      continue
    fi
    docker rm -f -v "$c" >/dev/null 2>&1 || true
  done
  if [ "${KEEP_CONTAINERS:-}" != "1" ] || [ "$FAILED" -eq 0 ]; then
    docker network rm "$NET" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

ok() {
  PASSED=$((PASSED + 1))
  echo "  ok   - $1"
}

fail() {
  FAILED=$((FAILED + 1))
  FAILURES+=("$1")
  echo "  FAIL - $1"
  if [ -n "${2:-}" ]; then
    echo "$2" | sed 's/^/         /'
  fi
}

# assert_eq <description> <expected> <actual>
assert_eq() {
  if [ "$2" = "$3" ]; then
    ok "$1"
  else
    fail "$1" "expected: '$2'"$'\n'"got:      '$3'"
  fi
}

# assert_cmd <description> <container> <shell command>
assert_cmd() {
  local out
  if out=$(docker exec "$2" bash -c "$3" 2>&1); then
    ok "$1"
  else
    fail "$1" "$out"
  fi
}

# assert_not_cmd <description> <container> <shell command>
assert_not_cmd() {
  local out
  if out=$(docker exec "$2" bash -c "$3" 2>&1); then
    fail "$1" "command unexpectedly succeeded: $3"$'\n'"$out"
  else
    ok "$1"
  fi
}

# remote_psql <host> <user> <password> <db>
# Connects from a separate client container, so pg_hba.conf password rules
# apply (connections from inside the server container are trusted).
remote_psql() {
  docker run --rm --network "$NET" -e PGPASSWORD="$3" --entrypoint psql "$IMAGE" \
    -X -v ON_ERROR_STOP=1 -h "$1" -U "$2" -d "$4" -c 'SELECT 1' >/dev/null 2>&1
}

# sql <container> <db> <query>  -- runs as the postgres superuser over the unix socket
sql() {
  docker exec -u postgres "$1" psql -X -At -v ON_ERROR_STOP=1 -d "$2" -c "$3" 2>&1
}

# wait_ready <container>
# Waits for the server to accept TCP connections. During first-time init the
# official entrypoint runs a temporary server that only listens on the unix
# socket, so checking TCP ensures the final server is up.
wait_ready() {
  local c="$1" i
  for ((i = 0; i < TIMEOUT; i++)); do
    if [ "$(docker inspect -f '{{.State.Running}}' "$c" 2>/dev/null)" != "true" ]; then
      echo "  container $c is not running; last logs:"
      docker logs --tail 40 "$c" 2>&1 | sed 's/^/    /'
      return 1
    fi
    if docker exec "$c" pg_isready -q -h 127.0.0.1 -p 5432 >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "  timeout waiting for $c; last logs:"
  docker logs --tail 40 "$c" 2>&1 | sed 's/^/    /'
  return 1
}

section() {
  echo
  echo "## $1"
}

# --------------------------------------------------------------------------
# setup
# --------------------------------------------------------------------------

echo "# Testing image: $IMAGE"
docker network create "$NET" >/dev/null
SUBNET=$(docker network inspect -f '{{(index .IPAM.Config 0).Subnet}}' "$NET")

# --------------------------------------------------------------------------
# 1. Startup and configuration from environment variables
# --------------------------------------------------------------------------

section "Startup and environment configuration"

docker run -d --name "$MAIN" --network "$NET" \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=supersecret \
  -e POSTGRES_DBNAME="datafs zasync" \
  -e POSTGRES_DBUSER=zope \
  -e POSTGRES_DBPASS=zopepass \
  -e POSTGRES_DBPARAMS="--lc-collate=C --lc-ctype=C --template=template0" \
  -e POSTGRES_CONFIG="max_connections = 150" \
  -e POSTGRES_CONFIG_SHARED_BUFFERS=128MB \
  -e POSTGRES_CONFIG_work_mem=8MB \
  -e POSTGRES_CRON_1="0 3 * * * postgres /postgresql.restore/database-backup.sh datafs" \
  "$IMAGE" >/dev/null

if wait_ready "$MAIN"; then
  ok "server starts and accepts TCP connections"
else
  fail "server starts and accepts TCP connections"
  echo
  echo "# Server did not start, aborting."
  exit 1
fi

if [ -n "$EXPECTED_MAJOR" ]; then
  assert_eq "server major version is $EXPECTED_MAJOR" "$EXPECTED_MAJOR" \
    "$(sql "$MAIN" postgres "SELECT current_setting('server_version_num')::int / 10000")"
fi

assert_cmd "include_dir points to /postgresql.conf.d" "$MAIN" \
  "grep -q \"^include_dir = '/postgresql.conf.d'\" /var/lib/postgresql/data/postgresql.conf"

# default.conf shipped in the image
assert_eq "default.conf applied (max_locks_per_transaction)" "512" \
  "$(sql "$MAIN" postgres 'SHOW max_locks_per_transaction')"
assert_eq "default.conf applied (synchronous_commit)" "off" \
  "$(sql "$MAIN" postgres 'SHOW synchronous_commit')"

# POSTGRES_CONFIG and POSTGRES_CONFIG_* (env overrides default.conf)
assert_eq "POSTGRES_CONFIG applied (max_connections)" "150" \
  "$(sql "$MAIN" postgres 'SHOW max_connections')"
assert_eq "POSTGRES_CONFIG_SHARED_BUFFERS overrides default.conf" "128MB" \
  "$(sql "$MAIN" postgres 'SHOW shared_buffers')"
assert_eq "POSTGRES_CONFIG_work_mem overrides default.conf" "8MB" \
  "$(sql "$MAIN" postgres 'SHOW work_mem')"
assert_eq "no invalid settings in config files" "0" \
  "$(sql "$MAIN" postgres 'SELECT count(*) FROM pg_file_settings WHERE error IS NOT NULL')"

# POSTGRES_DBNAME / POSTGRES_DBUSER / POSTGRES_DBPASS / POSTGRES_DBPARAMS
for db in datafs zasync; do
  assert_eq "database $db exists and is owned by zope" "zope" \
    "$(sql "$MAIN" postgres "SELECT pg_get_userbyid(datdba) FROM pg_database WHERE datname = '$db'")"
  assert_eq "POSTGRES_DBPARAMS applied to $db (collation C)" "C" \
    "$(sql "$MAIN" postgres "SELECT datcollate FROM pg_database WHERE datname = '$db'")"
done

if remote_psql "$MAIN" zope zopepass datafs; then
  ok "zope can log in from the network with POSTGRES_DBPASS"
else
  fail "zope can log in from the network with POSTGRES_DBPASS"
fi
if remote_psql "$MAIN" zope wrong datafs; then
  fail "zope login from the network with a wrong password is rejected"
else
  ok "zope login from the network with a wrong password is rejected"
fi
if remote_psql "$MAIN" postgres supersecret postgres; then
  ok "superuser can log in from the network with POSTGRES_PASSWORD"
else
  fail "superuser can log in from the network with POSTGRES_PASSWORD"
fi

# setup-permissions.sh default replication networks
assert_cmd "pg_hba.conf allows replication from default docker/rancher networks" "$MAIN" \
  "grep -q '^host replication all 172.16.0.0/12 trust' /var/lib/postgresql/data/pg_hba.conf && \
   grep -q '^host replication all 10.0.0.0/8 trust' /var/lib/postgresql/data/pg_hba.conf"

# --------------------------------------------------------------------------
# 2. Cron
# --------------------------------------------------------------------------

section "Cron"

assert_cmd "POSTGRES_CRON_1 written to /etc/cron.d/postgres" "$MAIN" \
  "grep -qF '0 3 * * * postgres /postgresql.restore/database-backup.sh datafs' /etc/cron.d/postgres"
assert_cmd "cron daemon is running" "$MAIN" \
  "for p in /proc/[0-9]*; do [ \"\$(cat \$p/comm 2>/dev/null)\" = cron ] && exit 0; done; exit 1"
assert_cmd "POSTGRES_* values with spaces exported intact to /etc/environment" "$MAIN" \
  "grep -qx 'POSTGRES_DBNAME=datafs zasync' /etc/environment"
assert_cmd "POSTGRES_CRON_* values with '*' exported intact to /etc/environment" "$MAIN" \
  "grep -qxF 'POSTGRES_CRON_1=0 3 * * * postgres /postgresql.restore/database-backup.sh datafs' /etc/environment"
assert_cmd "PG* variables exported to /etc/environment" "$MAIN" \
  "grep -qx 'PGDATA=/var/lib/postgresql/data' /etc/environment"
assert_not_cmd "no Debian apt-compat cron job" "$MAIN" "test -e /etc/cron.daily/apt-compat"
assert_not_cmd "no Debian dpkg cron job" "$MAIN" "test -e /etc/cron.daily/dpkg"
assert_not_cmd "no Debian e2scrub_all cron job" "$MAIN" "test -e /etc/cron.d/e2scrub_all"

# --------------------------------------------------------------------------
# 3. Backup / restore scripts
# --------------------------------------------------------------------------

section "Backup and restore scripts"

sql "$MAIN" datafs "CREATE TABLE t (id int PRIMARY KEY, v text); INSERT INTO t VALUES (1, 'before-backup');" >/dev/null
assert_cmd "database-backup.sh creates /postgresql.backup/datafs.gz" "$MAIN" \
  "chown postgres /postgresql.backup && gosu postgres /postgresql.restore/database-backup.sh datafs && \
   gunzip -t /postgresql.backup/datafs.gz"
sql "$MAIN" datafs "DELETE FROM t; INSERT INTO t VALUES (2, 'after-backup');" >/dev/null
assert_cmd "database-restore.sh restores datafs from the dump" "$MAIN" \
  "gosu postgres /postgresql.restore/database-restore.sh datafs"
assert_eq "restored data matches the backup" "1|before-backup" \
  "$(sql "$MAIN" datafs 'SELECT id, v FROM t ORDER BY id')"
assert_eq "restored database is owned by zope" "zope" \
  "$(sql "$MAIN" postgres "SELECT pg_get_userbyid(datdba) FROM pg_database WHERE datname = 'datafs'")"

# --------------------------------------------------------------------------
# 4. Restart keeps data and configuration
# --------------------------------------------------------------------------

section "Restart"

docker restart "$MAIN" >/dev/null
if wait_ready "$MAIN"; then
  ok "server comes back after restart"
  assert_eq "data persists after restart" "1|before-backup" \
    "$(sql "$MAIN" datafs 'SELECT id, v FROM t ORDER BY id')"
  assert_eq "configuration persists after restart" "150" \
    "$(sql "$MAIN" postgres 'SHOW max_connections')"
  assert_eq "include_dir not duplicated after restart" "1" \
    "$(docker exec "$MAIN" grep -c postgresql.conf.d /var/lib/postgresql/data/postgresql.conf)"
else
  fail "server comes back after restart"
fi

docker rm -f -v "$MAIN" >/dev/null 2>&1

# --------------------------------------------------------------------------
# 5. Streaming replication
# --------------------------------------------------------------------------

section "Replication"

docker run -d --name "$MASTER" --network "$NET" --network-alias master \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DBNAME=datafs \
  -e POSTGRES_DBUSER=zope \
  -e POSTGRES_DBPASS=zope \
  -e POSTGRES_REPLICATION_NETWORK="$SUBNET" \
  -e POSTGRES_CONFIG_shared_buffers=128MB \
  -e POSTGRES_CONFIG_wal_level=replica \
  -e POSTGRES_CONFIG_max_wal_senders=8 \
  -e POSTGRES_CONFIG_hot_standby=on \
  "$IMAGE" >/dev/null

if wait_ready "$MASTER"; then
  ok "master starts"
else
  fail "master starts"
fi

assert_cmd "POSTGRES_REPLICATION_NETWORK written to pg_hba.conf" "$MASTER" \
  "grep -qF 'host replication all $SUBNET trust' /var/lib/postgresql/data/pg_hba.conf"

sql "$MASTER" datafs "CREATE TABLE r (id int); INSERT INTO r VALUES (1);" >/dev/null

docker run -d --name "$REPLICA" --network "$NET" \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_REPLICATE_FROM=master \
  -e POSTGRES_CONFIG_shared_buffers=128MB \
  -e POSTGRES_CONFIG_wal_level=replica \
  -e POSTGRES_CONFIG_max_wal_senders=8 \
  -e POSTGRES_CONFIG_hot_standby=on \
  "$IMAGE" >/dev/null

if wait_ready "$REPLICA"; then
  ok "replica starts"
  assert_eq "replica is in recovery mode" "t" \
    "$(sql "$REPLICA" postgres 'SELECT pg_is_in_recovery()')"
  assert_eq "replica has data from base backup" "1" \
    "$(sql "$REPLICA" datafs 'SELECT count(*) FROM r')"

  sql "$MASTER" datafs "INSERT INTO r VALUES (2);" >/dev/null
  got=""
  for ((i = 0; i < 30; i++)); do
    got=$(sql "$REPLICA" datafs 'SELECT count(*) FROM r')
    [ "$got" = "2" ] && break
    sleep 1
  done
  assert_eq "new rows on master are streamed to replica" "2" "$got"
  assert_eq "master sees one streaming replica" "1" \
    "$(sql "$MASTER" postgres "SELECT count(*) FROM pg_stat_replication WHERE state = 'streaming'")"
  assert_not_cmd "replica rejects writes" "$REPLICA" \
    "gosu postgres psql -X -v ON_ERROR_STOP=1 -d datafs -c 'INSERT INTO r VALUES (3)'"
else
  fail "replica starts"
fi

# --------------------------------------------------------------------------
# summary
# --------------------------------------------------------------------------

echo
echo "# $IMAGE: $PASSED passed, $FAILED failed"
if [ "$FAILED" -gt 0 ]; then
  printf '#   - %s\n' "${FAILURES[@]}"
  exit 1
fi
exit 0
