FROM postgres:9.5
MAINTAINER "EEA: IDM2 A-Team" <eea-edw-a-team-alerts@googlegroups.com>

RUN mkdir -p /postgresql.conf.d \
 && mv /docker-entrypoint.sh /master-entrypoint.sh

COPY replica-entrypoint.sh /docker-entrypoint.sh /
COPY crond.sh setup-env.py /bin/
COPY setup-*.sh /docker-entrypoint-initdb.d/
COPY default.conf /postgresql.conf.d/
