# Changelog

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
