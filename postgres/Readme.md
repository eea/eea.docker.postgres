# PostgreSQL with replication support (ZODB RelStorage ready)

Docker image for PostgreSQL with replication support and ZODB RelStorage ready

This image is generic, thus you can obviously re-use it within
your non-related EEA projects.

 - Debian: **Jessie**
 - PostgreSQL: **9.6**
 - Expose: **5432**

## Supported tags and respective Dockerfile links

  - `:latest` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/master/postgres/Dockerfile) - Debian: **Jessie**, PostgreSQL: **9.6**
  - `:9.6s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.6s/postgres/Dockerfile) - PostgreSQL: **9.6**
  - `:9.5s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.5s/postgres/Dockerfile) - PostgreSQL: **9.5**
  - `:9.4s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.4s/postgres/Dockerfile) - PostgreSQL: **9.4**
  - `:9.3s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.3s/postgres/Dockerfile) - PostgreSQL: **9.3**
  - `:9.2s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.2s/postgres/Dockerfile) - PostgreSQL: **9.2**
  - `:9.1s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.1s/postgres/Dockerfile) - PostgreSQL: **9.1**

### Stable and immutable tags

  - `:9.6-2.0` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.6-1.0/postgres/Dockerfile) - PostgreSQL: **9.6** Release: **2.0**
  - `:9.5-2.0` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.5-1.0/postgres/Dockerfile) - PostgreSQL: **9.5** Release: **2.0**
  - `:9.4-2.0` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.4-1.0/postgres/Dockerfile) - PostgreSQL: **9.4** Release: **2.0**
  - `:9.3-2.0` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.3-1.0/postgres/Dockerfile) - PostgreSQL: **9.3** Release: **2.0**
  - `:9.2-2.0` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.2-1.0/postgres/Dockerfile) - PostgreSQL: **9.2** Release: **2.0**
  - `:9.1-2.0` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.1-1.0/postgres/Dockerfile) - PostgreSQL: **9.1** Release: **2.0**

See [older versions](https://github.com/eea/eea.docker.postgres/releases)

## Base docker image

 - [hub.docker.com](https://registry.hub.docker.com/u/eeacms/postgres)

## Source code

  - [github.com](http://github.com/eea/eea.docker.postgres)

## Changelog

  - [CHANGELOG.md](https://github.com/eea/eea.docker.postgres/blob/master/CHANGELOG.md)

## Installation

1. Install [Docker](https://www.docker.com/).

2. Install [Docker Compose](https://docs.docker.com/compose/).

## Simple usage

    $ docker run --name=pg1 \
                 -e POSTGRES_USER=postgres \
                 -e POSTGRES_PASSWORD=postgres \
                 -e POSTGRES_DBNAME=datafs zasync \
                 -e POSTGRES_DBUSER=zope \
                 -e POSTGRES_DBPASS=zope \
             eeacms/postgres

Or using docker-compose:

    postgres:
      image: eeacms/postgres
      ports:
      - "5432:5432"
      environment:
        POSTGRES_USER: postgres
        POSTGRES_PASSWORD: postgres
        POSTGRES_DBNAME: datafs zasync
        POSTGRES_DBUSER: zope
        POSTGRES_DBPASS: zope
      volumes:
      - postgres_data:/var/lib/postgresql/data

## PostgreSQL replication

Start master node:

    $ docker run --name=master \
                 -e POSTGRES_USER=postgres \
                 -e POSTGRES_PASSWORD=postgres \
                 -e POSTGRES_DBNAME=datafs zasync \
                 -e POSTGRES_DBUSER=zope \
                 -e POSTGRES_DBPASS=zope \
                 -e POSTGRES_CONFIG_wal_level=hot_standby \
                 -e POSTGRES_CONFIG_max_wal_senders=8 \
                 -e POSTGRES_CONFIG_wal_keep_segments=8 \
                 -e POSTGRES_CONFIG_hot_standby=on \
            eeacms/postgres

Start replica:

    $ docker run --name=replica1 \
                 --link=master \
                 -e POSTGRES_REPLICATE_FROM=master \
                 -e POSTGRES_USER=postgres \
                 -e POSTGRES_PASSWORD=postgres \
                 -e POSTGRES_CONFIG_wal_level=hot_standby \
                 -e POSTGRES_CONFIG_max_wal_senders=8 \
                 -e POSTGRES_CONFIG_wal_keep_segments=8 \
                 -e POSTGRES_CONFIG_hot_standby=on \
        eeacms/postgres

or using docker-compose:

    master:
      image: eeacms/postgres
      environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DBNAME=datafs zasync
      - POSTGRES_DBUSER=zope
      - POSTGRES_DBPASS=zope
      - POSTGRES_CONFIG_wal_level=hot_standby
      - POSTGRES_CONFIG_max_wal_senders=8
      - POSTGRES_CONFIG_wal_keep_segments=8
      - POSTGRES_CONFIG_hot_standby=on
      volumes:
      - master_data:/var/lib/postgresql/data

    replica:
      image: eeacms/postgres
      tty: true
      stdin_open: true
      links:
      - master
      environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_CONFIG_wal_level=hot_standby
      - POSTGRES_CONFIG_max_wal_senders=8
      - POSTGRES_CONFIG_wal_keep_segments=8
      - POSTGRES_CONFIG_hot_standby=on
      - POSTGRES_REPLICATE_FROM=master
      volumes:
      - replica_data:/var/lib/postgresql/data

Customize your deployment by changing environment variables.
See [Supported environment variables](#env) section bellow.

**You may want to restore existing PostgreSQL database**,
within data container. See section [Restore existing database](#restore)


## Persistent data as you wish
The PostgreSQL database is kept in a
[data-only container](https://medium.com/@ramangupta/why-docker-data-containers-are-good-589b3c6c749e)
named *data*. The data container keeps the persistent data for a production environment and
[must be backed up](https://github.com/paimpozhil/docker-volume-backup).

So if you are running in a development environment, you can skip the backup and delete
the container if you want.

On a production environment you would probably want to backup the container at regular intervals.
The data container can also be easily
[copied, moved and be reused between different environments](https://docs.docker.com/userguide/dockervolumes/#backup-restore-or-migrate-data-volumes).


<a name="restore"></a>
## Restore existing database


### Extract PostgreSQL database from the container

    $ cd eea.docker.postgres
    $ docker-compose up -d
    $ docker exec -it eeadockerpostgres_postgres_1 \
      bash -c "gosu postgres pg_dump datafs | gzip > /postgresql.backup/datafs.gz"
    $ ls /var/lib/docker/volumes/www-postgres-dump/_data

### Restore PostgreSQL database from backup

**WARNING:**
**NEVER do this directly on PRODUCTION. This will DROP your existing database**

    $ cd eea.docker.postgres
    $ docker-compose up -d
    $ docker cp datafs.gz eeadockerpostgres_postgres_1:/postgresql.backup/
    $ docker exec eeadockerpostgres_postgres_1 \
             gosu postgres /postgresql.restore/database-restore.sh datafs

<a name="env"></a>
## Supported environment variables

* `POSTGRES_USER` This optional environment variable is used in conjunction
   with POSTGRES_PASSWORD to set a user and its password. This variable will
   create the specified user with superuser power and a database with the same name.
   If it is not specified, then the default user of `postgres` will be used.
* `POSTGRES_PASSWORD` This environment variable is recommend for you to use
  the PostgreSQL image. This environment variable sets the superuser password
  for PostgreSQL. The default superuser is defined by the POSTGRES_USER
  environment variable. Default `postgres`
* `POSTGRES_DBNAME` Create multiple databases (space separated) within PostgreSQL with `POSTGRES_DBUSER` as owner.
  E.g. POSTGRES_DBNAME=datafs zasync
* `POSTGRES_DBUSER` Owner for `POSTGRES_DBNAME`
* `POSTGRES_DBPASS` Password for `POSTGRES_DBUSER`
* `POSTGRES_REPLICATE_FROM` Start a PostgreSQL replica of the given master

You can also override postgres configuration via environment variables by using
`POSTGRES_CONFIG_` prefix. Example:

    POSTGRES_CONFIG_MAX_CONNECTIONS=200
    POSTGRES_CONFIG_SHARED_BUFFERS=4GB

Also you can configure `recovery.conf` by using `RECOVERY_CONFIG_` environment variables.

See [PostgreSQL Documentation](http://www.postgresql.org/docs/9.5/static/runtime-config.html) for supported parameters.
You should also check [Tuning Your PostgreSQL Server](https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server)

In the same way you can define maintenance cron jobs by using
`POSTGRES_CRON_` prefix. Example to backup nighly `datafs` database at 3 AM:

    POSTGRES_CRON_1=0 3 * * * postgres /postgresql.restore/database-backup.sh datafs

or restore Staging DB daily at 5 AM:

    POSTGRES_CRON_2=0 5 * * * postgres /postgresql.restore/database-restore.sh datafs

## Copyright and license

The Initial Owner of the Original Code is European Environment Agency (EEA).
All Rights Reserved.

The Original Code is free software;
you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation;
either version 2 of the License, or (at your option) any later
version.


## Funding

[European Environment Agency (EU)](http://eea.europa.eu)
