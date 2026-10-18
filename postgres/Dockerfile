FROM ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23

# Upstream renders its SSD config into /etc on every start; a read-only root needs it rendered here.
ENV PGDATA=/var/lib/postgresql/data/pgdata
RUN cp /var/postgresql-conf-tpl/postgresql.ssd.conf /etc/postgresql/postgresql.conf \
 && sed -i "s@##PGDATA@${PGDATA}@" /etc/postgresql/postgresql.conf
COPY postgres-start /usr/local/bin/postgres-start
COPY initdb/ /docker-entrypoint-initdb.d/
# The user immich's data directory has been owned by since it was created.
USER 70:70
ENTRYPOINT ["/usr/local/bin/postgres-start"]
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
