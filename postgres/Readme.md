# PostgreSQL with replication support (ZODB RelStorage ready)

Docker image for PostgreSQL with replication support and ZODB RelStorage ready

This image is generic, thus you can obviously re-use it within
your non-related EEA projects.

## Supported tags and respective Dockerfile links

  - `:latest` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/master/postgres/Dockerfile) (default)
  - `:9.5s` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.5s/postgres/Dockerfile)
  - `:9.5` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.5/postgres/Dockerfile)
  - `:9.4` [*Dockerfile*](https://github.com/eea/eea.docker.postgres/blob/9.4/postgres/Dockerfile)

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
      image: eeacms/postgres:9.5
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
      sh -c "pg_dump -U zope datafs | gzip > /postgresql.backup/datafs.gz"
    $ ls backup/

### Restore PostgreSQL database from backup

**WARNING:**

- **NEVER do this directly on PRODUCTION**
- Make sure you're restoring your backup within **an empty PostgreSQL database**.
  For this you can either remove existing docker data container
  **docker-compose rm -v data**
  or manually add the database using createdb utility


      $ cd eea.docker.postgres
      $ cp /path/to/my/backups/datafs.gz backup/
      $ docker-compose up -d
      $ docker exec -it eeadockerpostgres_postgres_1 \
        sh -c "gunzip -c /postgresql.backup/datafs.gz | psql -U zope datafs"


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

See [PostgreSQL Documentation](http://www.postgresql.org/docs/9.5/static/runtime-config.html) for supported parameters.
You should also check [Tuning Your PostgreSQL Server](https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server)

In the same way you can define maintenance cron jobs by using
`POSTGRES_CRON_` prefix: Example:

    POSTGRES_CRON_1=0 0 * * * postgres pg_dump database | gzip > /postgresql.backup/database.gz

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
