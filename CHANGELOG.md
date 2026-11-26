# Changelog

## 1.2 (2026-11-26)

- Upgrade to 17.12
- Remove Debian default cron jobs (apt-compat, dpkg, e2scrub_all) from the image
- Fix `/etc/environment` for cron jobs: values with spaces or `*` were truncated
- Add functional tests in `tests/run.sh`

## 1.1 (2025-09-01)

- Postgres version 17.11
- OS Debian Trixie

## 1.0 (2024-07-08)

- Postgres version 16.3
- OS Debian Bullseye
