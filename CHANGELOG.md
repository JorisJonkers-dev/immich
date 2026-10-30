# Changelog

## [1.2.0](https://github.com/JorisJonkers-dev/immich/compare/v1.1.1...v1.2.0) (2026-10-30)


### Features

* declare its LAN exposure, so the estate edge renders their routes ([#23](https://github.com/JorisJonkers-dev/immich/issues/23)) ([257a833](https://github.com/JorisJonkers-dev/immich/commit/257a833feec2e0b486d5692a9635e62cf8519cad))

## [1.1.1](https://github.com/JorisJonkers-dev/immich/compare/v1.1.0...v1.1.1) (2026-10-21)


### Bug Fixes

* machine learning starts without gunicorn's control socket, which the read-only root refuses ([#14](https://github.com/JorisJonkers-dev/immich/issues/14)) ([0bbd8c9](https://github.com/JorisJonkers-dev/immich/commit/0bbd8c9f820f3e4dae02bf255069144705c9ff0f)), closes [#13](https://github.com/JorisJonkers-dev/immich/issues/13)

## [1.1.0](https://github.com/JorisJonkers-dev/immich/compare/v1.0.1...v1.1.0) (2026-10-21)


### Features

* the images lock records each image's upstream version, and an upstream bump releases ([#9](https://github.com/JorisJonkers-dev/immich/issues/9)) ([dc9970b](https://github.com/JorisJonkers-dev/immich/commit/dc9970bd1f5ae20e5fc46748ddb13d7f0b0b0366))

## [1.0.1](https://github.com/JorisJonkers-dev/immich/compare/v1.0.0...v1.0.1) (2026-10-18)


### Bug Fixes

* create immich's extensions in template1, so the database the catalog creates has them ([#5](https://github.com/JorisJonkers-dev/immich/issues/5)) ([8ddeddc](https://github.com/JorisJonkers-dev/immich/commit/8ddeddc061cc5aec81f58c04a45f0ec30018d0aa))

## 1.0.0 (2026-10-17)


### Features

* immich's server, machine learning and Postgres under the restricted posture, mounting the media library, and its Project Intent ([72af40f](https://github.com/JorisJonkers-dev/immich/commit/72af40f5ccf1998985b126b05f1a37c641ba7a1e))
