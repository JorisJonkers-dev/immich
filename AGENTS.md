# Agents

Guidance for any coding agent working in this repository. It holds the estate's Immich server, machine learning and Postgres images, delivered as the Project immich.

The repo's agent contract is [CLAUDE.md](CLAUDE.md); the estate-wide conventions are at https://github.com/JorisJonkers-dev/workspace/blob/main/CLAUDE.md.

## Build and test

- Lint shell: `shellcheck server/immich-start postgres/postgres-start scripts/*.sh`
- Build the three images from `server`, `ml` and `postgres`, then run `scripts/smoke-test.sh immich-server:ci immich-ml:ci immich-postgres:ci`
- Lint workflows: `actionlint .github/workflows/*.yml`
