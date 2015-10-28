#!/usr/bin/env python

import os

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
