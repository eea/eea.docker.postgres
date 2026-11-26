#!/bin/bash
set -e

# Provide POSTGRES_CRON_* via environment variable
rm -rf /etc/cron.d/postgres /etc/environment
# Iterate over variable names (not `env` output) so values containing
# spaces or '*' are neither split nor glob-expanded.
for ENVVAR in $(compgen -e); do
    case "$ENVVAR" in
        POSTGRES_CRON*)
            printenv "$ENVVAR" >> /etc/cron.d/postgres
            ;;
    esac
    case "$ENVVAR" in
        PG*|POSTGRES_*)
            VALUE="${!ENVVAR}"
            # /etc/environment is line based: skip multi-line values
            if [[ "$VALUE" != *$'\n'* ]]; then
                echo "$ENVVAR=$VALUE" >> /etc/environment
            fi
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
