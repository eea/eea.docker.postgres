#!/usr/bin/env python3

import os
PGDATA = os.environ.get('PGDATA', '/var/lib/postgresql/data')

#
# Setup postgresql.conf
#
zenv_conf = "/postgresql.conf.d/zenv.conf"
if not os.path.isfile(zenv_conf):
    configuration = []
    for variable in os.environ:
        if variable == 'POSTGRES_CONFIG':
            value = os.environ[variable]
            configuration.append(value)
            continue

        if variable == 'RECOVERY_CONFIG':
            value = os.environ[variable]
            configuration.append(value)
            continue


        if not variable.startswith("POSTGRES_CONFIG_") and not variable.startswith("RECOVERY_CONFIG_"):
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

