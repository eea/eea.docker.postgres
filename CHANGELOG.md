# Changelog

## 2017-04-25 (Release 3.0)

- Support PostgreSQL configuration via multiline env `POSTGRES_CONFIG`

- Support PostgresSQL configuration of `recovery.conf` via multiline env `RECOVERY_CONFIG`

- Support PostgresSQL cron jobs configuration via multiline env `POSTGRES_CRONS`

## 2017-04-25 (Release 2.1)

- Add ENV for paths `PG_ARCHIVE`, `PG_CONFD`, `PG_BACKUP`, `PG_RESTORE`
  and fix permissions within.

## 2017-02-24

- Release 2.0

## 2016-10-05

- Upgrade to Postgres 9.6
- Add tags for older PostgresSQL versions (9.3, 9.2, 9.1)

## 2016-07-21

- Fix recovery.conf via environment variables

## 2016-07-04

- Add script to easily backup database to `/postgresql.backup/` folder

## 2016-06-17

- Add possibility to configure recovery.conf via `RECOVERY_CONFIG_` env vars
- Various bug fixes

## 2016-04-29

- Add possibility to define cron jobs using `POSTGRES_CRON_*` env variables
- Add basic support for replication via `POSTGRES_REPLICATE_FROM` env variable
- Add script to easily restore database from `pg_dump gzip archive`

## 2016-03-29

- Drop chaperone process manager
- Upgrade to Postgres 9.5

## 2015-12-23

- Security review (refs #31597)
  - Add chaperone process manager
  - Start postgres container with non-root user
- Leave data container up-and-running

## 2015-08-12

- Add support for multiple user databases init on first run
  (e.g. `POSTGRES_DBNAME=datafs zasync`)

## 2015-07-10

Initial public release

- PostgreSQL
