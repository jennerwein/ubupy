# Changelog

Released images are available on
[Docker Hub](https://hub.docker.com/r/jennerwein/ubupy/tags).

## 3.0.2 — 2026-09-26

- Merged the apt layers into one; `psql` is now installed together with the
  other packages.
- Locale variables are set after `locale-gen`, so the build no longer prints
  locale warnings.
- Added OCI image labels (`version`, `created`, `source`, `licenses`, ...).
- Added MIT `LICENSE`, license notice for `badwolf.vim`, `.dockerignore`
  and this changelog.
- Rewrote the README; translated comments to English.

## 3.0.1 — 2026-04-25

- Improvements; tagged as `latest`.

## 3.0.0 — 2026-04-21

- Based on `ubuntu:26.04`.

## 2.1.1-dev — 2026-03-11

- PostgreSQL client (`psql`) version 18.

## 2.1-dev — 2026-03-10

- Development build based on `ubuntu:26.04`.

## 2.0.3 — 2026-03-10

- Improvements, updated packages.

## 2.0.2 — 2026-01-10

- Updated packages.

## 2.0.1 — 2025-10-31

- Added `wheel` to the virtual environment.

## 2.0.0 — 2025-10-31

- New start of the project.
