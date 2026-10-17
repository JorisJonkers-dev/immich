# immich

[Immich](https://github.com/immich-app/immich) at `immich.jorisjonkers.dev`, as
the estate runs it: upstream's server, machine learning and Postgres images,
changed only so that they run under the estate's restricted posture.
deploy-kit delivers them as the Project `immich`.

## What the images change

Each image runs as a numeric non-root user with a read-only root filesystem
and every capability dropped.

- `server/` runs as `deploy` (1000:1000), the user that owns `/srv/media`.
  Photos it writes into the media library are then files Samba can edit.
  `immich-start` builds the machine learning URL from the separate host and
  port the estate delivers, then starts upstream's `start.sh`.
- `ml/` is machine learning on CPU, as 1000:1000. Its models cache in `/cache`.
- `postgres/` is upstream's Postgres 14 with vectorchord, running as uid 70,
  which owns immich's data directory. Upstream renders its SSD configuration
  into `/etc` on every start; this image renders it at build time instead, then
  runs upstream's entrypoint.

## Running it

`deploy/immich.project.yml` and `deploy/env/` declare the Project:
- the server mounts the Platform document's `media` library at `/data`, below
  `Photos`, with write access;
- its database is `immich_db` on immich's own Postgres, whose catalog the
  estate applies;
- the job queue is the platform's Valkey;
- machine learning runs on CPU until deploy-kit renders a GPU request
  (JorisJonkers-dev/deploy-kit#398).

Each release builds the images and publishes the Intent Fragment that the
estate composes.

`scripts/smoke-test.sh` starts every image restricted beside Valkey. Postgres
initialises, and the server migrates and serves with its library written as
1000:1000. CI runs it on every change.

## Licence

Immich is licensed under the GNU Affero General Public License v3, and so is
this repository: see [LICENSE](LICENSE).
