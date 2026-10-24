# spec: homeserver

Self-hosted services at home: Proxmox host (Home Assistant VM, Docker VM) and Unraid NAS. Backlog:
`changes/HOMESERVER-BACKLOG.md`. Secrets are referenced by location, never by value.

## Current

Observed 2026-10-24/25 in session (screenshots, `docker ps`, `ss -tlnp`, `psql`, container logs).
Everything else carries `[UNVERIFIED]`.

### Hosts

| Host | Role | Version | Last updated |
|---|---|---|---|
| Proxmox host | hypervisor | `[UNVERIFIED]` | ~1 year ago (Luis) |
| ↳ VM Home Assistant OS | home automation | update offered: Core 2026.1.2, OS 15.2; repair "Unsupported system – os_version" open 9 months | `[UNVERIFIED]` |
| ↳ VM `debian-docker` | Docker host, compose files in `~/docker-yml/` (git repo) | Debian `[UNVERIFIED]` | `[UNVERIFIED]` |
| Unraid `ServerWD`, `192.168.2.3` | NAS + Docker | Unraid 7.2.5, host PHP 8.3.29 (webGUI) | `[UNVERIFIED]` |

### `debian-docker` containers (running, all others absent)

| Container | Image | Host ports | Note |
|---|---|---|---|
| swag | `lscr.io/linuxserver/swag:latest` | 1808→80, 1443→443 | reverse proxy; updated 2026-10-24 → PHP 8.5.12 |
| pihole | `pihole/pihole:latest` | 53 tcp/udp, **80, 443** | v6 (no PHP): Core 6.4, Web 6.4.1, FTL 6.5 |
| portainer | `portainer/portainer-ce:latest` | 8000, 9443 | Docker admin |
| remotely | `immybot/remotely:latest` | 5000 | remote desktop server |
| dashy | `lissy93/dashy:latest` | 4000 | dashboard |
| stirling-pdf | `frooodle/s-pdf:latest` | 2223 | PDF tools |
| wireguard | `lscr.io/linuxserver/wireguard:latest` | 51820/udp | VPN |
| cups | `olbat/cupsd:latest` | — (cupsd on host 631) | print server |
| ddns-cloudflare | `oznu/cloudflare-ddns:latest` | — | DDNS |

- Compose dirs with **no running container**: `cal_com`, `n8n-ai-starter`, `umami`, `recovered*`.
- All published ports bind `0.0.0.0`/`[::]`. Router port forwards `[UNVERIFIED]`.

### Unraid containers

| State | Containers |
|---|---|
| started | nextcloud, postgresql15, immich_server, immich_machine_learning, immich_postgres, immich_redis, syncthing |
| stopped | vaultwarden, Gitea, Gitea-Runner, backuppc, Kopia, restic-rest-server, UrBackup, CouchDB, Redis, openvscode-server, DiskSpeed, Unraid-API |

### Nextcloud (Unraid)

- **Up, 35.0.2.2** (`occ status` 2026-10-25: `maintenance: false`, `needsDbUpgrade: false`), PHP 8.5.12.
  Upgraded 32.0.5 → 35.0.2 in 0011.
- Image `lscr.io/linuxserver/nextcloud:version-35.0.2` (pinned, no patch updates). Unraid auto-update
  plugin state `[UNVERIFIED]`.
- Cron: `busybox crond` in container, `cron.php` as `abc`, `backgroundjobs_mode` = `cron`.
- Apps disabled: `notes` 6.1.0, `richdocuments` 12.0.1 (disabled as incompatible during upgrade), plus
  shipped-off apps (admin_audit, encryption, suspicious_login, user_ldap, files_antivirus, app_api,
  twofactor_nextcloud_notification). Talk (`spreed`) not installed.
- Log: `logfile => 'home/data/nextcloud.log'` (relative), `loglevel => 0`; actual file
  `/data/nextcloud.log` (host `/mnt/user/NextcloudShare/nextcloud.log`), 516,332,470,669 B on
  2026-10-25.
- Public at `cloud.luiswaller.com`; `trusted_proxies` = `172.18.0.3` on Unraid network `proxynet`
  (container unidentified). Container port 443 → host 444.
- Config `/mnt/user/appdata/nextcloud/www/nextcloud/config/config.php` (only config file; no `NC_*`
  env). Contains DB + Gmail SMTP credentials.
- DB `nextcloud_db` on `postgresql15` (`192.168.2.3:5432`). Connects as `nextcloud_app`, which owns the
  database, schema `public`, 201 tables and their sequences.
- `db:schema:check -v`: extra indexes `fs_storage_path_prefix`, `fed_inv_open_email_uniq`,
  `text_steps_doc_id_id_index`; `oc_share_external.id` autoincrement diff; 24 unattributed tables
  (`oc_talk_*` ×17, `oc_ex_*` ×7).
- serverinfo DB checks: cache hit ratio 64.4 %, largest table 106,637 dead tuples, `oc_share` > 1M
  sequential scans; connections 8/100, latency 3.11 ms.
- Backups in `/mnt/user/backup/` (DB dumps `600`; config copy `700`):
  `nextcloud-appdata-2026-10-24/` (pre-upgrade, `755`), `nextcloud-db-2026-10-24.sql`,
  `nextcloud-db-32.0.11-2026-10-24.sql`, `nextcloud-db-35.0.2-2026-10-25.sql` (896 MB, 201
  `CREATE TABLE`), `nextcloud-config-35.0.2-2026-10-25/`. User files (`/mnt/user/NextcloudShare`) not
  backed up.
- LSIO tag scheme (Docker Hub, 2026-10-25): current major `version-X.Y.Z`, previous major
  `previous-version-X.Y.Z`; older majors stop receiving images (no 32.0.12+, no 33.0.10).

### `postgresql15` roles

| Role | Attributes | Use |
|---|---|---|
| db_admin | superuser | admin login |
| nextcloud_user | superuser, createrole, createdb, replication, bypassrls | unknown; installer account `[UNVERIFIED]` |
| nextcloud_owner | NOLOGIN | owns nothing since 0011 (`REASSIGN OWNED`); referenced by `OWNER TO` in pre-0011 dumps |
| nextcloud_app | — | Nextcloud's login; owns `nextcloud_db` |
| oc_luis | createdb | created by Nextcloud ≤ 30 installer (`oc_<admin>`); unused `[UNVERIFIED]` |
| gitea | — | owns `gitea_db` |

## Invariants

- Internet-facing: reverse proxy (443) and WireGuard (51820/udp) only. Admin UIs (Proxmox, Unraid,
  Portainer, Pi-hole, remotely) stay LAN/VPN.
- Stateful apps (Nextcloud, Immich, Postgres) run pinned tags with auto-update off; upgrades are manual,
  one major per hop.
- DB dump + appdata copy before every stateful upgrade.
- Each app's DB login owns its database objects.
- Stopped containers are updated before they are started.
- No secret values in this repo.

## Gaps

1. ~~Nextcloud down: maintenance mode, upgrade blocked by table ownership (`nextcloud_owner` vs login
   `nextcloud_app`).~~ — closed 2026-10-25: 0011, `occ status` 35.0.2.2, maintenance false.
2. Credentials pasted into an agent chat 2026-10-24: Gmail app password, Nextcloud DB password (weak).
3. No patch routine: Proxmox host, HA, Unraid ~1 year unpatched; `latest` + auto-update caused the
   32→35 jump. No update notification.
4. Router port forwards unknown. Pi-hole holds VM 80/443; Portainer 9443/8000, remotely 5000, DNS 53,
   CUPS 631 bind all interfaces.
5. Ingress path for `cloud.luiswaller.com` unclear: SWAG (VM) vs the unidentified proxy `172.18.0.3`
   (Unraid). Version of that proxy unknown.
6. Home Assistant: Core + OS updates pending; unsupported-OS repair open 9 months.
7. Postgres role sprawl: `nextcloud_user` is superuser + createrole; `nextcloud_owner` (owns nothing
   since 0011), `oc_luis` leftovers.
8. Nextcloud config: `loglevel => 0` (debug), relative `logfile` path, 3 LSIO nginx confs older than
   shipped samples.
9. PHP incident CVE unidentified → patch status of Nextcloud (PHP 8.5.12) and Unraid (8.3.29) unknown.
10. Pi-hole behind latest: Core 6.4→6.5, Web 6.4.1→6.6.1, FTL 6.5→6.8.
11. No running backup: backuppc, Kopia, restic-rest-server, UrBackup all stopped. Restore never tested
    `[UNVERIFIED]`.
12. Stale compose dirs without containers (`cal_com`, `n8n-ai-starter`, `umami`, `recovered*`): intent
    unknown.
13. Proxmox host version and Debian VM patch level unknown.
14. Nextcloud log never rotates: relative `logfile` → writes fall back to `/data/nextcloud.log`
    (`Log/File.php`), rotation checks the configured path (`Log/Rotate.php`); with `loglevel 0` the file
    reached ~516 GB in the user-data share. Pre-upgrade appdata copy is `755` and holds the old
    `config.php`.
15. Nextcloud schema drift: 3 extra indexes, 1 autoincrement diff, 24 orphan tables (Talk, old AppAPI
    `[UNVERIFIED]`); `notes`/`richdocuments` disabled, usage unknown.
16. `postgresql15` performance: 106,637 dead tuples after migrations; cache hit ratio 64.4 % with
    measurement skewed by dumps; `shared_buffers` value and Unraid RAM unknown.
