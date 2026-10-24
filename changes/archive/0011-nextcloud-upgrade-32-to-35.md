# 0011 — nextcloud-upgrade-32-to-35

- status: done
- domain: specs/homeserver.md
- opened: 2026-10-24
- closed: 2026-10-25

## Problem

Nextcloud on Unraid (`cloud.luiswaller.com`, public) was down during a PHP security incident.

- Unraid showed the container `started`, but the log said: `Can't start Nextcloud because the version
  of the data (32.0.5.0) is more than one major version behind the docker image version (35.0.2.2)`.
  Cause: image `lscr.io/linuxserver/nextcloud:latest` plus an unattended update jumped three majors.
- First hop to `previous-version-32.0.11` failed: `Database error when running migration
  34000Date20260318095645 for app core … SQLSTATE[42501]: Insufficient privilege: 7 ERROR: must be
  owner of table oc_jobs`. Config `dbuser` = `nextcloud_app` (`occ config:system:get dbuser`, no `NC_*`
  env, single `config.php`); database, schema, 183 tables and 161 sequences owned by `nextcloud_owner`
  (NOLOGIN) (`pg_tables`, `pg_sequences`, `pg_namespace`).
- Result: `maintenance => true`, `version => 32.0.5.0`, service unavailable.

## Baseline

- Availability: down (maintenance mode), unknown duration before 2026-10-24.
- Version: 32.0.5.0 data; Nextcloud 32 end-of-life (help.nextcloud.com/t/249146, 2026-09-10:
  "32.0.15 is the last release of Nextcloud 32").
- Upgrade attempts: 1 of 1 failed.

## Options

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| A. `REASSIGN OWNED BY nextcloud_owner TO nextcloud_app`, then hop one major at a time | Login owns its objects = Nextcloud installer's model (`lib/private/Setup/PostgreSQL.php`: `CREATE DATABASE … OWNER "<dbuser>"`); every future migration works | Drops the owner/app split | **chosen** |
| B. `GRANT nextcloud_owner TO nextcloud_app` | One line, keeps split | Same effective rights, extra indirection; new tables get mixed owners | rejected |
| C. Temporarily point `config.php` at superuser `nextcloud_user` | Fast | App runs as superuser; new tables owned by a third role | rejected |
| D. Restore 32.0.5 image and stay | No migration risk | EOL major, still unpatched, public | rejected |
| E. Official `nextcloud:<major>` image for newer point releases (32.0.15, 33.0.10) | Newest patch level per hop | Different filesystem layout (`/var/www/html` vs LSIO `/config` + `/app/www`) → breaks appdata | rejected |

Sources:
- Docker Hub tag API, paginated (`page_size` caps at 100): LSIO builds only current major as
  `version-*` and previous major as `previous-version-*`; no image exists for 32.0.12–32.0.15
  (GHCR manifest 404) or 33.0.10.
- `version.php` `$OC_VersionCanBeUpgradedFrom` at v33.0.9 / v34.0.5 / v35.0.2: accepts previous major at
  `major.minor` granularity → any 32.0.x can go to 33.0.9.
- `lib/private/Setup/PostgreSQL.php` (v25, v27: role `oc_<admin>`; v32.0.11: `oc_admin`) explains the
  leftover role `oc_luis`.

## Decision

A. Deciding axis: future upgrades succeed without manual DB fixes. B lost on clarity (same rights,
more moving parts), C on least privilege, D on security (public EOL instance during a PHP incident),
E on compatibility with the LSIO appdata layout.

Path: `previous-version-32.0.11` → `previous-version-33.0.9` → `previous-version-34.0.5` →
`version-35.0.2`; maintenance mode kept on across all hops, off once at the end.

## Tasks

- [x] Backup before hop 1: `/mnt/user/backup/nextcloud-appdata-2026-10-24/` (appdata copy),
      `/mnt/user/backup/nextcloud-db-2026-10-24.sql` (896 MB, taken after the failed attempt; failed
      migration rolled back).
- [x] `postgresql15`: `REASSIGN OWNED BY nextcloud_owner TO nextcloud_app;` in `nextcloud_db`.
- [x] `occ upgrade` → 32.0.11.1; dump `nextcloud-db-32.0.11-2026-10-24.sql`.
- [x] Unraid template Repository → 33.0.9, 34.0.5, 35.0.2; LSIO init ran each upgrade on start.
- [x] `occ db:add-missing-indices|columns|primary-keys`; `occ maintenance:mode --off`;
      `occ maintenance:repair --include-expensive`.
- [x] Backup at 35: `nextcloud-db-35.0.2-2026-10-25.sql` + `nextcloud-config-35.0.2-2026-10-25/`;
      dumps `chmod 600`, config copy `go-rwx`.

## Verification

```sh
docker exec nextcloud occ status                      # version 35.0.2.2, maintenance false, needsDbUpgrade false
docker exec postgresql15 psql -U db_admin -d nextcloud_db -c "select tableowner, count(*) from pg_tables where schemaname='public' group by 1;"   # only nextcloud_app
docker exec nextcloud occ setupchecks                 # no ✗ except transient cron after maintenance
grep -c '^CREATE TABLE' /mnt/user/backup/nextcloud-db-35.0.2-2026-10-25.sql   # 201
```

## Outcome

- Down → up. 32.0.5.0 → **35.0.2.2**, PHP 8.5.12. Four hops, 1 failure (ownership) fixed in place.
- Ownership: 183 tables, 161 sequences, schema and database now `nextcloud_app`.
- Tables 183 → 201. `db:add-missing-indices` added 18 indexes, replaced 3.
- `setupchecks`: WebDAV, HTTPS, headers, code integrity, email test pass. Cron: `busybox crond` running,
  `cron.php` executing as `abc`; first post-maintenance check 582 s (backlog run), re-check pending.
- Apps disabled as incompatible by the upgrade: `notes`, `richdocuments` (still disabled at 35).
- Surprises:
  1. `setupchecks` "Database configuration" failures are performance only (serverinfo): cache hit
     ratio 64.4 % (skewed by 3 full dumps + migrations), 106,637 dead tuples (post-migration), `oc_share`
     > 1M sequential scans.
  2. `db:schema:check -v`: 3 extra indexes + 1 autoincrement diff; 24 orphan tables (`oc_talk_*` ×17 —
     Talk not installed; `oc_ex_*` ×7, probably old AppAPI `[UNVERIFIED]`).
  3. **`/data/nextcloud.log` = 516,332,470,669 B (~516 GB).** `logfile` is relative
     (`home/data/nextcloud.log`): `Log/File.php` falls back to `<datadirectory>/nextcloud.log` for
     writing, `Log/Rotate.php` checks the configured path without fallback → never rotates; plus
     `loglevel 0`. Tracked as homeserver#14 / backlog H19.
  4. Credentials (Gmail app password, DB password) pasted into the agent chat while reading
     `config.php` → homeserver#2, unchanged by this change.
- Folded into `specs/homeserver.md`: Nextcloud + Postgres sections, gaps 1 and 7 updated, gaps 14–16 added.
