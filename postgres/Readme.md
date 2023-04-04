# PostgreSQL with replication support (ZODB RelStorage ready)

Docker image for PostgreSQL with replication support and ZODB RelStorage ready

This image is generic, thus you can obviously re-use it within
your non-related EEA projects.

 - Debian: **Stretch**
 - PostgreSQL: **9.6**
 - Expose: **5432**


## Supported tags and respective Dockerfile links

  - `:latest` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/master/postgres/Dockerfile) - PostgreSQL: **14**
  - `:14s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/14s/postgres/Dockerfile) - PostgreSQL: **14**
  - `:13s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/13s/postgres/Dockerfile) - PostgreSQL: **13**
  - `:12s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/12s/postgres/Dockerfile) - PostgreSQL: **12**
  - `:11s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/11s/postgres/Dockerfile) - PostgreSQL: **11**
  - `:10s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/10s/postgres/Dockerfile) - PostgreSQL: **10**
  - `:9.6s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.6s/postgres/Dockerfile) - PostgreSQL: **9.6**
  - `:9.5s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.5s/postgres/Dockerfile) - PostgreSQL: **9.5**


### Stable and immutable tags

  - `:14.7-1.0` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/14.7-1.0/postgres/Dockerfile) - PostgreSQL: **14.7** Release: **1.0**
  - `:13.10-1.0` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/13.10-1.0/postgres/Dockerfile) - PostgreSQL: **13.10** Release: **1.0**
  - `:12.14-1.0` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/12.14-1.0/postgres/Dockerfile) - PostgreSQL: **12.14** Release: **1.0**
  - `:11.19-4.1` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/11.19-4.1/postgres/Dockerfile) - PostgreSQL: **11.19** Release: **4.1**
  - `:10.23-4.2` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/10.23-4.2/postgres/Dockerfile) - PostgreSQL: **10.23** Release: **4.2**
  - `:9.6-4.2` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.6.24-4.2/postgres/Dockerfile) - PostgreSQL: **9.6.24** Release: **4.2**
  - `:9.5-3.7` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.5-3.6/postgres/Dockerfile) - PostgreSQL: **9.5.25** Release: **3.7**

See [older versions](https://github.com/eea/eea.docker.postgres/releases)


## Base docker image

 - [hub.docker.com](https://hub.docker.com/r/eeacms/postgres)


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

    version: "2"
    services:
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
        - postgres-data:/var/lib/postgresql/data
    volumes:
      postgres-data:


## PostgreSQL replication

Start master node:

    $ docker run --name=master \
                 -e POSTGRES_USER=postgres \
                 -e POSTGRES_PASSWORD=postgres \
                 -e POSTGRES_DBNAME="datafs zasync" \
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

    version: "2"
    services:
      master:
        image: postgres-dev
        environment:
          POSTGRES_USER: "postgres"
          POSTGRES_PASSWORD: "postgres"
          POSTGRES_DBNAME: "datafs zasync"
          POSTGRES_DBUSER: "zope"
          POSTGRES_DBPASS: "zope"
          POSTGRES_CONFIG_wal_level: "hot_standby"
          POSTGRES_CONFIG_max_wal_senders: "8"
          POSTGRES_CONFIG_wal_keep_segments: "8"
          POSTGRES_CONFIG_hot_standby: "on"
        volumes:
        - master-data:/var/lib/postgresql/data

      replica:
        image: postgres-dev
        depends_on:
        - master
        environment:
          POSTGRES_USER: "postgres"
          POSTGRES_PASSWORD: "postgres"
          POSTGRES_CONFIG_wal_level: "hot_standby"
          POSTGRES_CONFIG_max_wal_senders: "8"
          POSTGRES_CONFIG_wal_keep_segments: "8"
          POSTGRES_CONFIG_hot_standby: "on"
          POSTGRES_REPLICATE_FROM: "master"
        volumes:
        - replica-data:/var/lib/postgresql/data

    volumes:
      master-data:
      replica-data:


Customize your deployment by changing environment variables.
See [Supported environment variables](#env) section bellow.

**You may want to restore existing PostgreSQL database**,
within data container. See section [Restore existing database](#restore)


## Where to Store Data

There are several ways to store data used by applications that run in Docker containers.
We encourage you to familiarize with the options available.

The [Docker documentation](https://docs.docker.com/engine/tutorials/dockervolumes/)
is a good starting point for understanding the different storage options and
variations, and there are multiple blogs and forum postings that discuss and
give advice in this area.


<a name="restore"></a>
## Restore existing database

### Extract PostgreSQL database from the container

    $ cd eea.docker.postgres
    $ docker-compose up -d
    $ docker exec -it eeadockerpostgres_postgres_1 \
             gosu postgres /postgresql.restore/database-backup.sh datafs
    $ docker cp eeadockerpostgres_postgres_1:/postgresql.backup/datafs.gz .

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
* `POSTGRES_DBPARAMS` Create POSTGRES_DBNAME with custom options, e.g.: `POSTGRES_DBPARAMS="--lc-collate=C --template=template0 --lc-ctype=C"`. See `createdb --help` for possible options.
* `POSTGRES_DBUSER` Owner for `POSTGRES_DBNAME`
* `POSTGRES_DBPASS` Password for `POSTGRES_DBUSER`
* `POSTGRES_REPLICATE_FROM` Start a PostgreSQL replica of the given master
* `POSTGRES_REPLICATION_NETWORK` Restrict replication only on this network (e.g.: `172.168.0.0/16`)
* `POSTGRES_CONFIG` Multiline environment variable to provide additional or to override postgres configuration.
* `RECOVERY_CONFIG` Multiline environment variables to add entries to `recovery.conf`
* `POSTGRES_CRONS` Multiline environment variable to define maintenance cron jobs (nighly backup, cleanup archive WALs)

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

## Troubleshooting

If you get errors like `FATAL: could not map anonymous shared memory: Cannot allocate memory`, lower the `shared_buffers` via environment variable (default `2G`):

    POSTGRES_CONFIG_shared_buffers=512MB

See also: [Tuning Your PostgreSQL Server](https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server)

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
