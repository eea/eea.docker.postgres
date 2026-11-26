# Changelog

Each entry is named after its release tag on GitHub and Docker Hub (`eeacms/postgres:<tag>`).

## 16.16-2 (2026-11-26)

- Upgrade to 16.16
- Upgrade to OS Trixie
- Remove Debian default cron jobs (apt-compat, dpkg, e2scrub_all) from the image
- Fix `/etc/environment` for cron jobs: values with spaces or `*` were truncated
- Add functional tests in `tests/run.sh`

## 16.9-1 (2025-05-28)

- Upgrade to 16.9

## 16.4-1.1 (2024-08-13)

- Upgrade to 16.4

## 16.3-1.0 (2024-07-08)

- Postgres version 16.3
- OS Debian Bookworm
