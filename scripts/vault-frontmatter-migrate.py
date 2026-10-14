#!/usr/bin/env python3
"""Vault frontmatter 7 -> 5 keys (change 0008).

Old: Created, Title, tags, Parent, Children, MOC, date      (permanent notes, MOCs)
     date, type, tags, parent, moc                        (daily notes)
New: Created, Title, tags, Parent, date / date, type, tags, Parent
     (Parent = exactly one link, nearest parent; key matched case-insensitively, written `Parent`)

Per note with a Parent/Children/MOC key (any case):
  Parent  <- first link of Parent, else first link of MOC, else empty
  every other link from Parent/MOC/Children that the body does not already contain
          -> appended under `# Links` (no link is lost)
  Children, MOC keys removed; all other keys and the body untouched.
  `[[Daily Notes]]` (unresolved) -> `[[800 Daily Notes/Daily Notes MOC]]` (RENAME).
Skipped: no frontmatter, .trash, .obsidian, sync-conflict files.

Usage:  vault-frontmatter-migrate.py [--vault PATH]            dry run, report only
        vault-frontmatter-migrate.py [--vault PATH] --apply    backup tarball, then write
"""
import argparse, os, re, sys, tarfile, time

LINK = re.compile(r'\[\[([^\]]*)\]\]')
KEY = re.compile(r'^([A-Za-z][^:]*):(.*)$')
TARGET_KEYS = ('parent', 'children', 'moc')
RENAME = {'Daily Notes': '800 Daily Notes/Daily Notes MOC'}   # unresolved link -> real note


def links(value_lines):
    out = []
    for v in value_lines:
        for m in LINK.findall(v):
            if m.strip() and '<%' not in m:   # drop `[[]]` and Templater leftovers
                out.append(RENAME.get(m.strip(), m.strip()))
    return out


def target(link):  # path part of `path#hdr|alias`, for duplicate checks
    return link.split('|')[0].split('#')[0].strip()


def split_fm(text):
    if not text.startswith('---\n'):
        return None
    end = text.find('\n---', 4)
    if end < 0:
        return None
    return text[4:end].split('\n'), text[end:]   # rest starts with '\n---'


def parse(lines):
    """-> ordered list of (key, [raw lines incl. continuation])"""
    blocks = []
    for ln in lines:
        m = KEY.match(ln)
        if m and not ln.startswith(' '):
            blocks.append([m.group(1), [ln]])
        elif blocks:
            blocks[-1][1].append(ln)
        else:
            blocks.append([None, [ln]])
    return blocks


def migrate(text):
    sp = split_fm(text)
    if not sp:
        return None, 'no-frontmatter'
    lines, rest = sp
    blocks = parse(lines)
    blocks = [[k.lower() if k and k.lower() in TARGET_KEYS else k, v] for k, v in blocks]
    keys = [k for k, _ in blocks]
    if not any(k in TARGET_KEYS for k in keys):
        return None, 'no-target-keys'
    val = {k: links(v) for k, v in blocks if k in TARGET_KEYS}
    cand = val.get('parent', []) + val.get('moc', [])
    parent = cand[0] if cand else None
    leftovers = [l for l in cand[1:] + val.get('children', [])
                 if parent is None or target(l) != target(parent)]

    new = []
    for k, v in blocks:
        if k in ('children', 'moc'):
            continue
        if k == 'parent':
            new.append(f'Parent: "[[{parent}]]"' if parent else 'Parent:')
            continue
        new.extend(v)
    if 'parent' not in keys:           # MOC-only note: insert Parent before `date:` (or at end)
        i = next((j for j, ln in enumerate(new) if ln.startswith('date:') and j > 0), len(new))
        new.insert(i, f'Parent: "[[{parent}]]"' if parent else 'Parent:')

    body = rest
    seen = {target(l) for l in LINK.findall(body)}
    add, done = [], set()
    for l in leftovers:
        t = target(l)
        if t not in seen and t not in done:
            add.append(f'[[{l}]]')
            done.add(t)
    if add:
        block = '\n'.join(add) + '\n'
        m = re.search(r'^# Links[ \t]*\n', body, re.M)
        if m:
            body = body[:m.end()] + block + body[m.end():]
        else:
            body = body.rstrip('\n') + '\n\n# Links\n' + block
    return '---\n' + '\n'.join(new) + body, {'parent': parent, 'moved_to_links': add,
                                               'from': 'Parent' if val.get('parent') else 'MOC' if parent else None}


def walk(vault):
    for dp, dn, fn in os.walk(vault):
        dn[:] = [d for d in dn if d not in ('.trash', '.obsidian', '.git') and not d.startswith('.st')]
        for f in fn:
            if f.endswith('.md') and 'sync-conflict' not in f:
                yield os.path.join(dp, f)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--vault', default=os.path.expanduser('~/luis_obsidian_vault'))
    ap.add_argument('--apply', action='store_true')
    ap.add_argument('-v', '--verbose', action='store_true', help='list every changed note')
    a = ap.parse_args()

    changes, stats = [], {'parent-from-Parent': 0, 'parent-from-MOC': 0, 'parent-empty': 0, 'links-appended': 0}
    for p in sorted(walk(a.vault)):
        text = open(p, encoding='utf-8').read()
        out, info = migrate(text)
        if out is None or out == text:
            continue
        changes.append((p, out, info))
        stats['parent-from-' + info['from'] if info['from'] else 'parent-empty'] += 1
        stats['links-appended'] += len(info['moved_to_links'])

    rel = lambda p: os.path.relpath(p, a.vault)
    print(f'notes to change: {len(changes)}')
    for k, v in stats.items():
        print(f'  {k}: {v}')
    print('\nnotes where links move from frontmatter to # Links:')
    for p, _, i in changes:
        if i['moved_to_links']:
            print(f'  {rel(p)}\n    Parent: {i["parent"]}\n    +Links: {", ".join(i["moved_to_links"])}')
    if a.verbose:
        for p, _, i in changes:
            print(f'  {rel(p)} -> {i["parent"]}')

    if not a.apply:
        print('\ndry run — nothing written. Re-run with --apply.')
        return
    bdir = os.path.expanduser('~/vault-backups')
    os.makedirs(bdir, exist_ok=True)
    bfile = os.path.join(bdir, time.strftime('vault-md-%Y%m%d-%H%M%S.tar.gz'))
    with tarfile.open(bfile, 'w:gz') as tar:
        for p, _, _ in changes:
            tar.add(p, arcname=rel(p))
    for p, out, _ in changes:
        tmp = p + '.migrate-tmp'
        with open(tmp, 'w', encoding='utf-8') as fh:
            fh.write(out)
        os.replace(tmp, p)
    print(f'\nwritten: {len(changes)} notes; backup of originals: {bfile}')


if __name__ == '__main__':
    sys.exit(main())
