# Changelog

## 2.0 (2026-11-26)

- Upgrade to 15.20
- Upgrade to OS Trixie
- Remove Debian default cron jobs (apt-compat, dpkg, e2scrub_all) from the image
- Fix `/etc/environment` for cron jobs: values with spaces or `*` were truncated
- Add functional tests in `tests/run.sh`

## 1.1 (2024-08-13)

- Upgrade to 15.8

## 1.0 (2024-07-08)

- Postgres version 15.7
- OS Debian Bullseye
