FROM ghcr.io/immich-app/immich-machine-learning:v2.7.5@sha256:a2501141440f10516d329fdfba2c68082e19eb9ba6016c061ac80d23beadf7f3

ENV HOME=/tmp
# gunicorn 25 opens a control socket in its working directory, which the read-only root refuses,
# and its failing thread can leave the forked worker hung (#13). Nothing here uses it.
ENV GUNICORN_CMD_ARGS=--no-control-socket
USER 1000:1000
