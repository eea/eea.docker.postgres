# Gotchas

## Changing the Debian base image (e.g. bullseye -> trixie)

The C library (glibc) version changes with the Debian release (bullseye 2.31,
bookworm 2.36, trixie 2.41). Text sort order can change between glibc versions,
so indexes on text columns built with the old version may silently return wrong
results. PostgreSQL warns with `collation version mismatch` on connect.

After upgrading an existing data directory to an image on a new Debian release,
run on every database:

    REINDEX DATABASE <db>;
    ALTER DATABASE <db> REFRESH COLLATION VERSION;

Databases created with `--lc-collate=C` are not affected.
