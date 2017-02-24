FROM postgres:9.4
MAINTAINER "EEA: IDM2 A-Team" <eea-edw-a-team-alerts@googlegroups.com>

RUN mkdir -p /postgresql.conf.d /postgresql.restore /postgresql.backup \
 && chown -R postgres:postgres /postgresql.restore /postgresql.backup \
 && mv /docker-entrypoint.sh /master-entrypoint.sh

COPY database-backup.sh database-restore.sh /postgresql.restore/
COPY replica-entrypoint.sh docker-entrypoint.sh /
COPY crond.sh setup-env.py /bin/
COPY setup-*.sh /docker-entrypoint-initdb.d/
COPY default.conf /postgresql.conf.d/

ENTRYPOINT ["/docker-entrypoint.sh"]
