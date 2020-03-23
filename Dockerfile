FROM alpine:3.11

FROM alpine:3.11 AS build_stage

LABEL maintainer "pacifier17"

RUN apk --update --no-cache add \
        autoconf \
        autoconf-doc \
        automake \
        c-ares \
        c-ares-dev \
        curl \
        gcc \
        libc-dev \
        libevent \
        libevent-dev \
        libtool \
        make \
        libressl-dev \
        file \
        pkgconf

RUN curl -Lso  "/tmp/pgbouncer.tar.gz" "https://pgbouncer.github.io/downloads/files/1.12.0/pgbouncer-1.12.0.tar.gz" && \
        file "/tmp/pgbouncer.tar.gz"

WORKDIR /tmp

RUN mkdir /tmp/pgbouncer && \
        tar -zxvf pgbouncer.tar.gz -C /tmp/pgbouncer --strip-components 1

WORKDIR /tmp/pgbouncer

RUN ./configure --prefix=/usr && \
        make

FROM alpine:3.11

RUN apk --update --no-cache add \
        libevent \
        libressl \
        ca-certificates \
        c-ares

WORKDIR /etc/pgbouncer
WORKDIR /var/log/pgbouncer

COPY --from=build_stage ["/tmp/pgbouncer", "/opt/pgbouncer"]
COPY ["entrypoint.sh", "/opt/pgbouncer"]

RUN chmod -R 777 /etc/pgbouncer /var/log/pgbouncer /opt/pgbouncer

WORKDIR /opt/pgbouncer
ENTRYPOINT ["/opt/pgbouncer/entrypoint.sh"]

