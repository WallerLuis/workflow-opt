# HOMESERVER BACKLOG

Candidates for `specs/homeserver.md`, ordered by risk removed ÷ effort within each bucket. Same rules as
`changes/BACKLOG.md`: a row becomes a decision only as `changes/NNNN-slug.md`; every row names its gap.

Lev: **H** = security exposure or outage · **M** = drift that will become H · **L** = tidy.

## Now

| # | Candidate | Gap | Lev | Effort |
|---|---|---|---|---|
| H1 | Revoke Gmail app password (myaccount.google.com/apppasswords), set new one in Nextcloud `config.php` | homeserver#2 | H | 10 min |
| H2 | Router: list port forwards; keep only 51820/udp + 80/443 → proxy; remove anything to 9443, 8000, 5000, 53, 631, VM:443 (Pi-hole) | homeserver#4 | H | 15 min |
| H3 | Fix Nextcloud DB ownership: `REASSIGN OWNED BY nextcloud_owner TO nextcloud_app`, then `occ upgrade`. Done = `occ status` shows 32.0.11, `maintenance: false` | homeserver#1 | H | 15 min |
| H4 | Finish Nextcloud chain 33.0.9 → 34.0.5 → 35.0.2 (tags in spec); backup before each hop; pin tag, auto-update off | homeserver#1, #3 | H | 1 h |
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
| H15 | Nextcloud config: `loglevel` 2, absolute `logfile`, merge 3 nginx confs with samples | homeserver#8 | L | 30 min |
| H16 | Update vaultwarden + Gitea images before next start, or remove | homeserver#3 | M | 15 min |
| H17 | Decide fate of `cal_com`, `n8n-ai-starter`, `umami`, `recovered*` compose dirs | homeserver#12 | L | 15 min |
| H18 | Pin image tags across `~/docker-yml` (replace `:latest`) for stateful services | homeserver#3 | M | 30 min |
