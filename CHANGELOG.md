# Changelog

## 3.1 (2026-11-26)

- Upgrade to 14.25
- Remove Debian default cron jobs (apt-compat, dpkg, e2scrub_all) from the image
- Fix `/etc/environment` for cron jobs: values with spaces or `*` were truncated
- Add functional tests in `tests/run.sh`

## 3.0 ( 2025-09-01)

- Upgrade to 14.24
- Upgrade to OS Trixie

## 2.1 (2024-08-13)

- Upgrade to 14.13

## 2.0 (2024-07-08)

- Upgrade to 14.12
- Upgrade to OS Bullseyes

## 1.0 (2023-04-04)

- Upgrade to 14.7
- Upgrade to OS Buster
- Refactor replication scripts
