# HOMESERVER BACKLOG

Candidates for `specs/homeserver.md`, ordered by risk removed ÷ effort within each bucket. Same rules as
`changes/BACKLOG.md`: a row becomes a decision only as `changes/NNNN-slug.md`; every row names its gap.

Lev: **H** = security exposure or outage · **M** = drift that will become H · **L** = tidy.

## Now

| # | Candidate | Gap | Lev | Effort |
|---|---|---|---|---|
| H1 | Revoke Gmail app password (myaccount.google.com/apppasswords), set new one in Nextcloud `config.php` | homeserver#2 | H | 10 min |
| H2 | Router: list port forwards; keep only 51820/udp + 80/443 → proxy; remove anything to 9443, 8000, 5000, 53, 631, VM:443 (Pi-hole) | homeserver#4 | H | 15 min |
| H19 | Nextcloud log: `loglevel` 2, `occ config:system:delete logfile`; extract level ≥ 2 from the 516 GB `/mnt/user/NextcloudShare/nextcloud.log` to `/mnt/user/backup/*.jsonl.gz`, then `truncate -s 0`; `chmod -R go-rwx` the pre-upgrade appdata copy. Done = `occ log:file` absolute, file < 100 MB, `df` +~516 GB | homeserver#14, #8 | H | 1–2 h (mostly unattended) |
| H4 | Nextcloud tag policy: `latest` + auto-update off for this container vs pinned `version-35.0.2`; verify Unraid auto-update plugin state; re-check `lastcron` < 300 s | homeserver#3 | H | 15 min |
| H5 | Identify the PHP incident CVE; check fixed versions against Nextcloud (8.5.12) and Unraid (8.3.29) | homeserver#9 | H | 15 min |
| H6 | Identify `172.18.0.3` on `proxynet` (`docker network inspect proxynet`); document ingress for `cloud.luiswaller.com`; update that proxy | homeserver#5 | H | 20 min |

## Next

| # | Candidate | Gap | Lev | Effort |
|---|---|---|---|---|
| H7 | Rotate `nextcloud_app` DB password (`ALTER ROLE` + `config.php`) | homeserver#2 | H | 10 min |
| H8 | Home Assistant: backup, then OS 15.2, then Core; clear unsupported-OS repair | homeserver#6 | M | 30 min |
| H9 | Unraid OS update (flash backup first) | homeserver#3 | M | 30 min |
| H10 | Proxmox host + Debian VM: record versions, `apt full-upgrade`, reboot | homeserver#3, #13 | M | 1 h |
| H11 | Pick one backup tool of the four stopped; DB dumps + appdata + photos; one test restore | homeserver#11 | H | half day |
| H12 | Update all `debian-docker` stacks (`docker compose pull && up -d` per dir); Pi-hole to latest | homeserver#3, #10 | M | 30 min |
| H13 | Postgres roles: strip superuser from `nextcloud_user`; drop `oc_luis`, `nextcloud_owner` after a fresh post-35 dump | homeserver#7 | M | 20 min |

## Later

| # | Candidate | Gap | Lev | Effort |
|---|---|---|---|---|
| H14 | Update notifications: Diun (notify) vs Renovate on `~/docker-yml` vs Unraid CA notify-only; pick one | homeserver#3 | M | 1 h |
| H15 | Nextcloud: merge 3 LSIO nginx confs with samples | homeserver#8 | L | 30 min |
| H20 | `VACUUM ANALYZE` on `nextcloud_db`; check `oc_share` row count; re-measure cache hit ratio after 1–2 weeks before touching `shared_buffers` | homeserver#16 | L | 15 min |
| H21 | Nextcloud schema drift: decide `notes`/`richdocuments` (enable or `app:remove`); after a fresh dump drop orphan `oc_talk_*` / `oc_ex_*` tables if unused | homeserver#15 | L | 30 min |
| H16 | Update vaultwarden + Gitea images before next start, or remove | homeserver#3 | M | 15 min |
| H17 | Decide fate of `cal_com`, `n8n-ai-starter`, `umami`, `recovered*` compose dirs | homeserver#12 | L | 15 min |
| H18 | Pin image tags across `~/docker-yml` (replace `:latest`) for stateful services | homeserver#3 | M | 30 min |
