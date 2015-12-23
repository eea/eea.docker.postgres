FROM postgres:9.4
MAINTAINER "Alin Voinea" <alin.voinea@eaudeweb.ro>

RUN apt-get update && \
    apt-get -y --no-install-recommends install python3-pip && \
    pip3 install chaperone && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /postgresql.conf.d
ADD setup-env.py /bin/
ADD setup-postgres.sh /docker-entrypoint-initdb.d/
ADD setup-schema.sh /docker-entrypoint-initdb.d/
ADD default.conf /postgresql.conf.d/

COPY docker-setup.sh /

RUN mkdir -p /etc/chaperone.d
COPY chaperone.conf /etc/chaperone.d/chaperone.conf

RUN chown 999:999 /dev/
USER postgres

ENTRYPOINT ["/usr/local/bin/chaperone"]
CMD ["--user", "postgres"]


