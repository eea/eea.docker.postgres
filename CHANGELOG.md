# Changelog

Each entry is named after its release tag on GitHub and Docker Hub (`eeacms/postgres:<tag>`).

## 14.25-4 (2026-11-26)

- Upgrade to 14.25
- Remove Debian default cron jobs (apt-compat, dpkg, e2scrub_all) from the image
- Fix `/etc/environment` for cron jobs: values with spaces or `*` were truncated
- Add functional tests in `tests/run.sh`

## 14.24-3 (2026-09-01)

- Upgrade to 14.24
- Upgrade to OS Trixie

## 14.18-1 (2025-05-28)

- Upgrade to 14.18

## 14.13-2.1 (2024-08-13)

- Upgrade to 14.13

## 14.12-2.0 (2024-07-08)

- Upgrade to 14.12
- Upgrade to OS Bullseyes

## 14.7-1.0 (2023-04-04)

- Upgrade to 14.7
- Upgrade to OS Buster
- Refactor replication scripts
