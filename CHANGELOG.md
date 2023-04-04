# Changelog

## 2023-04-04 (Release 4.1)

- Upgrade to 11.19
- Upgrade to buster

## 2022-09-09 (Release 4.0)

- Upgrade to 11.16
- Fix default.conf and apply more RelStorage tunning:
  https://relstorage.readthedocs.io/en/latest/postgresql/setup.html

## 2021-10-18 (Release 3.6)

- Upgrade to 10.18, OS Stretch

## 2018-10-05 (Release 3.5)

- Add possibility to specify backup/restore gzip path

## 2018-06-11 (Release 3.4)

- Fix setup-env.py `/usr/bin/env: ‘python’: No such file or directory`

## 2018-06-08 (Release 3.3)

- Upgrade to the latest PostgreSQL versions (9.6.9, 9.5.13, 9.4.18, 9.3.23)

## 2018-04-17 (Release 3.2)

- Make PostgreSQL related environment variables available to cronjobs

## 2018-01-30 (Release 3.1)

- Support PostgreSQL `createdb` options via `POSTGRES_DBPARAMS` environment variable. e.g.:

      $ docker run -d --name=riot \
                   -e POSTGRES_DBNAME=riot \
                   -e POSTGRES_DBUSER=riot \
                   -e POSTGRES_DBPASS=riot \
                   -e POSTGRES_DBPARAMS="--lc-collate=C --lc-ctype=C --template=template0"  \
                eeacms/postgres

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
