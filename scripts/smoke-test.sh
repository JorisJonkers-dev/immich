#!/usr/bin/env bash
# Starts every image restricted (its own uid, a read-only root, every capability dropped) beside
# Valkey: Postgres initialises as uid 70 with immich's extensions in template1, machine learning
# answers, and the server migrates a database it owns but no superuser made for it, and serves
# with its library writable as deploy (1000:1000).
# Usage: scripts/smoke-test.sh <server-image> <ml-image> <postgres-image>
set -euo pipefail
server_image=$1
ml_image=$2
postgres_image=$3
net=immich-smoke
containers=(smoke-postgres smoke-valkey smoke-ml smoke-server)

cleanup() {
  docker rm -f "${containers[@]}" >/dev/null 2>&1 || true
  docker network rm "$net" >/dev/null 2>&1 || true
}
trap cleanup EXIT
cleanup
docker network create "$net" >/dev/null

restricted=(--network "$net" --read-only --cap-drop ALL --security-opt no-new-privileges)

docker run -d --name smoke-postgres "${restricted[@]}" --user 70:70 \
  --tmpfs '/var/lib/postgresql/data:uid=70,gid=70' --tmpfs '/var/run/postgresql:uid=70,gid=70' \
  --tmpfs '/tmp:uid=70,gid=70,mode=1777' \
  -e POSTGRES_USER=immich -e POSTGRES_PASSWORD=smoke -e POSTGRES_DB=immich \
  -e POSTGRES_INITDB_ARGS=--data-checksums -e PGDATA=/var/lib/postgresql/data/pgdata \
  "$postgres_image" >/dev/null
docker run -d --name smoke-valkey --network "$net" valkey/valkey:8-alpine >/dev/null
docker run -d --name smoke-ml "${restricted[@]}" --user 1000:1000 \
  --tmpfs '/cache:uid=1000,gid=1000' --tmpfs '/tmp:uid=1000,gid=1000,mode=1777' "$ml_image" >/dev/null

until docker exec smoke-postgres pg_isready -U immich -d immich >/dev/null 2>&1; do
  [ "$(docker inspect -f '{{.State.Running}}' smoke-postgres)" = true ] || { docker logs smoke-postgres 2>&1 | tail -30; exit 1; }
  sleep 2
done
echo "postgres accepts connections as uid 70"

# As the estate's catalog does: a database created from template1, owned by a role that is no
# superuser, which immich signs in as. Its extensions must already be there.
docker exec smoke-postgres psql -v ON_ERROR_STOP=1 -U immich -d postgres -q \
  -c "CREATE ROLE app LOGIN PASSWORD 'smoke-app'" -c "CREATE DATABASE immich_db OWNER app" >/dev/null

docker run -d --name smoke-server "${restricted[@]}" --user 1000:1000 \
  --tmpfs '/data:uid=1000,gid=1000' --tmpfs '/tmp:uid=1000,gid=1000,mode=1777' \
  -e DB_HOSTNAME=smoke-postgres -e DB_PORT=5432 -e DB_USERNAME=app -e DB_PASSWORD=smoke-app \
  -e DB_DATABASE_NAME=immich_db -e REDIS_HOSTNAME=smoke-valkey -e REDIS_PORT=6379 \
  -e IMMICH_ML_HOST=smoke-ml -e IMMICH_ML_PORT=3003 "$server_image" >/dev/null

# probe <container> <url>: polls the url from inside the container until it answers.
probe() {
  for _ in $(seq 1 90); do
    if docker exec "$1" node -e "fetch('$2').then(r => process.exit(r.ok ? 0 : 1), () => process.exit(1))" >/dev/null 2>&1 \
      || docker exec "$1" python3 -c "import urllib.request; urllib.request.urlopen('$2', timeout=3)" >/dev/null 2>&1; then
      echo "$1 serves $2"
      return 0
    fi
    if [ "$(docker inspect -f '{{.State.Running}}' "$1")" != true ]; then
      docker logs "$1" 2>&1 | tail -40
      echo "$1 exited before it served $2" >&2
      return 1
    fi
    sleep 5
  done
  docker logs "$1" 2>&1 | tail -40
  echo "$1 never served $2" >&2
  return 1
}
probe smoke-ml http://127.0.0.1:3003/ping
probe smoke-server http://127.0.0.1:2283/api/server/ping
probe smoke-server http://smoke-ml:3003/ping

# The server's library files land as deploy, which Samba edits as.
owners=$(docker exec smoke-server sh -c 'find /data -mindepth 1 -maxdepth 2 -printf "%U:%G\n" | sort -u')
echo "library owned by: $owners"
[ "$owners" = "1000:1000" ] || { echo "the library holds files not owned by 1000:1000" >&2; exit 1; }

for c in smoke-postgres smoke-ml smoke-server; do
  others=$(docker top "$c" -eo pid,uid,comm | tail -n +2 | awk '$2 != 70 && $2 != 1000')
  [ -z "$others" ] || { echo "$c runs a process as another uid: $others" >&2; exit 1; }
done
echo "smoke test passed"
