#!/bin/bash
set -e

# Provide POSTGRES_CRON_* via environment variable
rm -rf /etc/cron.d/postgres
for item in `env`; do
   case "$item" in
       POSTGRES_CRON*)
            ENVVAR=`echo $item | cut -d \= -f 1`
            printenv $ENVVAR >> /etc/cron.d/postgres
            ;;
   esac
done

if [ -f /etc/cron.d/postgres ]; then
    sed -i "s/^session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g" /etc/pam.d/cron
    echo "Running cron(s)                                    "
    echo "***************************************************"
    cat /etc/cron.d/postgres
    echo "***************************************************"
    cron
fi
