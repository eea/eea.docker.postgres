FROM postgres:9.4
MAINTAINER "Alin Voinea" <alin.voinea@eaudeweb.ro>

RUN mkdir -p /postgresql.conf.d
ADD setup-postgres.sh /docker-entrypoint-initdb.d/
ADD setup-schema.sh /docker-entrypoint-initdb.d/

CMD ["postgres"]
