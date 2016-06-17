#!/usr/bin/env python

import os
PGDATA = os.environ.get('PGDATA', '/var/lib/postgresql/data')

#
# Setup postgresql.conf
#
zenv_conf = "/postgresql.conf.d/zenv.conf"
if not os.path.isfile(zenv_conf):
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
        with open(zenv_conf, "w") as conf:
            conf.write(configuration)

#
# Setup recovery.conf for replication
#
recovery_conf = os.path.join(PGDATA, "/recovery.conf")
recovery_done =  os.path.join(PGDATA, "/recovery.done")
if not (os.path.isfile(recovery_conf) or os.path.isfile(recovery_done)):
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
        with open(recovery_conf, "w") as conf:
            conf.write(configuration)
