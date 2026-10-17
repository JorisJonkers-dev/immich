FROM ghcr.io/immich-app/immich-server:v2.7.5@sha256:c15bff75068effb03f4355997d03dc7e0fc58720c2b54ad6f7f10d1bc57efaa5

COPY immich-start /usr/local/bin/immich-start
# deploy, which owns the media library: what immich writes, Samba can edit.
USER 1000:1000
ENTRYPOINT ["tini", "--", "/usr/local/bin/immich-start"]
CMD []
