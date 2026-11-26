# Changelog

Each entry is named after its release tag on GitHub and Docker Hub (`eeacms/postgres:<tag>`).

## 17.12-1 (2026-11-26)

- Upgrade to 17.12
- Remove Debian default cron jobs (apt-compat, dpkg, e2scrub_all) from the image
- Fix `/etc/environment` for cron jobs: values with spaces or `*` were truncated
- Add functional tests in `tests/run.sh`

## 17.11-1 (2026-09-01)

- Postgres version 17.11
- OS Debian Trixie

## 17.5-1 (2025-05-28)

- Postgres version 17.5
- OS Debian Bullseye
