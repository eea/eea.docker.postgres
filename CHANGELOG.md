# Changelog

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
  (e.g. POSTGRES_DBNAME=datafs zasync)

## 2015-07-10

Initial public release

- PostgreSQL
