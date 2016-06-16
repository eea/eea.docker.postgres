#!/usr/bin/env python

import os
PGDATA = os.environ.get('PGDATA', '/var/lib/postgresql/data')
#
# Setup postgresql.conf
#
configuration = []
for variable in os.environ:
    if not variable.startswith("POSTGRES_CONFIG_"):
        continue

    tag = variable[16:]
    tag = tag.lower()
    if not tag:
        continue

    value = os.environ[variable].strip('"\'')

    configuration.append(u"%s = %s" % (tag, value))

if configuration:
    configuration.append(u"")
    configuration = u"\n".join(configuration)
    with open("/postgresql.conf.d/zenv.conf", "w") as conf:
        conf.write(configuration)
#
# Setup recovery.conf for replication
#
configuration = []
for variable in os.environ:
    if not variable.startswith("RECOVERY_CONFIG_"):
        continue

    tag = variable[16:]
    tag = tag.lower()
    if not tag:
        continue

    value = os.environ[variable].strip('"\'')
    configuration.append(u"%s = %s" % (tag, value))

if configuration:
    configuration.append(u"")
    configuration = u"\n".join(configuration)
    rpath = os.path.join(PGDATA, "/recovery.conf")
    with open(rpath, "w") as conf:
        conf.write(configuration)
