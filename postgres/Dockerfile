FROM postgres:11.16-stretch
MAINTAINER "EEA: IDM2 A-Team" <eea-edw-a-team-alerts@googlegroups.com>

ENV PG_ARCHIVE=/var/lib/postgresql/archive \
    PG_CONFD=/postgresql.conf.d \
    PG_RESTORE=/postgresql.restore \
    PG_BACKUP=/postgresql.backup

COPY database-backup.sh database-restore.sh /postgresql.restore/
COPY replica-entrypoint.sh entrypoint.sh /usr/local/bin/
COPY crond.sh setup-env.py /bin/
COPY setup-*.sh /docker-entrypoint-initdb.d/
COPY default.conf /postgresql.conf.d/

RUN rm -f /etc/apt/sources.list.d/pgdg.list \
 && apt-get update -q \
 && apt-get -y install apt-transport-https \
 && printf "deb http://apt-archive.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
 && apt-get install -y --no-install-recommends python3 iputils-ping cron\
 && apt-get clean \
 && mkdir -p $PG_ARCHIVE $PG_CONFD $PG_RESTORE $PG_BACKUP \
 && chown -R postgres:postgres $PG_ARCHIVE $PG_CONFD $PG_RESTORE $PG_BACKUP \
 && mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/master-entrypoint.sh \
 && mv /usr/local/bin/entrypoint.sh /usr/local/bin/docker-entrypoint.sh \
 && ln -s usr/local/bin/master-entrypoint.sh / \
 && ln -s usr/local/bin/replica-entrypoint.sh /

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]
