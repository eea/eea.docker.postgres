FROM postgres:12.20-bullseye

LABEL maintainer="EEA: IDM2 A-Team <eea-edw-a-team-alerts@googlegroups.com>"

ENV PG_ARCHIVE=/var/lib/postgresql/archive \
    PG_CONFD=/postgresql.conf.d \
    PG_RESTORE=/postgresql.restore \
    PG_BACKUP=/postgresql.backup

COPY database-backup.sh database-restore.sh /postgresql.restore/
COPY entrypoint.sh /usr/local/bin/
COPY crond.sh setup-env.py /bin/
COPY setup-*.sh /docker-entrypoint-initdb.d/
COPY default.conf /postgresql.conf.d/

RUN apt-get update -q \
 && apt-get install -y --no-install-recommends python3 iputils-ping cron\
 && apt-get clean \
 && mkdir -p $PG_ARCHIVE $PG_CONFD $PG_RESTORE $PG_BACKUP \
 && chown -R postgres:postgres $PG_ARCHIVE $PG_CONFD $PG_RESTORE $PG_BACKUP \
 && ln -s /usr/local/bin/entrypoint.sh / 


ENTRYPOINT ["entrypoint.sh"]

CMD ["postgres"]
