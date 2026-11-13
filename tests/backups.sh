#!/usr/bin/env bash
# Tests for the `backups` stow package (backups/backups/).
# Runs the real Makefile recipes against a throwaway local restic repository,
# so the excludes and the retention policy are exercised for real and R2 is
# never reached. Dependency-free on purpose: bash + coreutils + restic, no bats.
# Run: bash tests/backups.sh
set -uo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
pkg=$repo/backups/backups

for f in Makefile excludes.txt run-unattended.sh; do
    if [[ ! -f $pkg/$f ]]; then
        echo "FAIL $pkg/$f is missing" >&2
        exit 1
    fi
done
if ! command -v restic >/dev/null; then
    echo "FAIL restic is not installed" >&2
    exit 1
fi

# Not under /tmp: the `**/tmp/*` exclude also matches an ancestor directory, so a
# fixture in /tmp/tmp.XXXX would be dropped whole and every "excludes" check
# would pass vacuously. Real homes have no tmp/ ancestor.
if [[ ! -d /dev/shm || ! -w /dev/shm ]]; then
    echo "FAIL /dev/shm is not writable" >&2
    exit 1
fi
work=$(mktemp -d -p /dev/shm backups-test.XXXXXX)
trap 'rm -rf "$work"' EXIT

pass=0
fail=0
ok() { pass=$((pass + 1)); printf 'ok   %s\n' "$1"; }
nok() {
    fail=$((fail + 1))
    printf 'FAIL %s\n' "$1"
    [[ $# -gt 1 ]] && printf '     %s\n' "$2"
}
assert_eq() { # name expected actual
    if [[ $2 == "$3" ]]; then ok "$1"; else nok "$1" "expected [$2] got [$3]"; fi
}
assert_contains() { # name needle haystack
    if [[ $3 == *"$2"* ]]; then ok "$1"; else nok "$1" "[$2] not found"; fi
}
assert_absent() { # name needle haystack
    if [[ $3 != *"$2"* ]]; then ok "$1"; else nok "$1" "[$2] is present"; fi
}

# Never reach R2 or the real restic cache. The real credentials come from
# `op run`, which these tests bypass with RESTIC=restic.
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY AWS_SECRET_KEY \
    RESTIC_PASSWORD_FILE RESTIC_PASSWORD_COMMAND
export RESTIC_REPOSITORY=$work/repo
export RESTIC_PASSWORD=test-only
export RESTIC_CACHE_DIR=$work/cache

home=$work/home
mk() { make -C "$pkg" RESTIC=restic BACKUP_PATH="${BP:-$home}" "$@" >>"$work/make.log" 2>&1; }
make_log_tail() { tail -n 8 "$work/make.log" 2>/dev/null; }

# --- defaults: nothing may touch plaintext credentials or surprise the user --

dry=$(make -n -C "$pkg" backup 2>&1)
assert_contains "backup runs restic through op run by default" 'op run --no-masking -- restic' "$dry"
assert_contains "backup passes exclude-caches and the exclude file" \
    '--exclude-caches --exclude-file=' "$dry"
assert_eq "the default command carries only op:// references, no literal credentials" '' \
    "$(grep -oE '(RESTIC_REPOSITORY|RESTIC_PASSWORD|AWS_[A-Z_]+)=[^ ]+' <<<"$dry" | grep -v '=op://' || true)"
assert_contains "OP_ITEM selects another vault" 'op://Work/restic-r2/password' \
    "$(make -n -C "$pkg" OP_ITEM=op://Work/restic-r2 backup 2>&1)"
assert_contains "the default goal is the read-only snapshot list" \
    'restic snapshots' "$(make -n -C "$pkg" 2>&1)"
assert_contains "restore lands outside the package directory" "$work/h/restic-restore" \
    "$(HOME=$work/h make -n -C "$pkg" restore 2>&1)"
assert_absent "mount never uses rm -rf" 'rm -rf' "$(make -n -C "$pkg" mount 2>&1)"

# --- excludes: a fixture home with things to keep and things to drop ---------

kept=(
    Documents/projects/app/src/main.rb
    Documents/projects/app/.git/HEAD
    Documents/notes/todo.md
    Documents/projects/other/data/small.db
    Documents/projects/AIH/api/src/app.py
    .config/app/config.toml
    .ssh/config
    .local/share/opencode/opencode.db
    .claude/projects/session.jsonl
)
dropped=(
    .cache/uv/archive/pkg.whl
    .npm/_cacache/index-v5/entry
    .ollama/models/blob
    .cargo/registry/crate
    .local/share/Trash/files/old.mp4
    .local/share/mise/installs/node/bin/node
    .local/state/noctalia/clipboard
    .var/app/org.example.App/cache/blob
    Documents/projects/app/node_modules/pkg/index.js
    Documents/projects/app/.venv/bin/python
    Documents/projects/app/__pycache__/main.cpython-313.pyc
    Documents/projects/app/vendor/bundle/gem.rb
    Documents/projects/app/tmp/cache/entry
    Documents/projects/app/log/development.log
    Documents/projects/app/db/dump.sql.gz
    Documents/projects/AIH/aiml-data-pipeline/storage/run.db
    Documents/projects/AIH/aih-confidence/data/analytics.db
    Documents/tools/cachey/blob
)
for p in "${kept[@]}" "${dropped[@]}"; do
    mkdir -p "$home/$(dirname "$p")"
    printf 'x' >"$home/$p"
done
# A directory marked with CACHEDIR.TAG is skipped by --exclude-caches.
printf 'Signature: 8a477f597d28d172789f06886806bc55\n' >"$home/Documents/tools/cachey/CACHEDIR.TAG"

if mk init && mk backup; then
    ok "init and backup succeed against a local repository"
else
    nok "init and backup succeed against a local repository" "$(make_log_tail)"
fi

listing=$(restic ls latest --recursive / 2>&1)
# Guard against a vacuous run: if nothing was backed up, every exclude check passes.
assert_contains "the backup is not empty" "$home/Documents/notes/todo.md" "$listing"
for p in "${kept[@]}"; do
    assert_contains "keeps $p" "$home/$p" "$listing"
done
for p in "${dropped[@]}"; do
    assert_absent "excludes $p" "$home/$p" "$listing"
done

# --- retention: `make prune` keeps 30 days, the newest snapshot and `archive` -

ret=$work/ret
mkdir -p "$ret"
printf 'x' >"$ret/file"
restic backup "$ret" --time "$(date -d '400 days ago' '+%F 12:00:00')" --tag archive >/dev/null 2>&1
for age in 2 5 10 45 90; do
    restic backup "$ret" --time "$(date -d "$age days ago" '+%F 12:00:00')" >/dev/null 2>&1
done
count() { restic snapshots --json --path "$ret" "$@" 2>/dev/null | grep -o '"short_id"' | wc -l; }
assert_eq "fixture has 6 snapshots before prune" '6' "$(count)"

if mk prune; then
    ok "prune succeeds"
else
    nok "prune succeeds" "$(make_log_tail)"
fi
assert_eq "prune keeps the 3 snapshots within 30 days plus the archive one" '4' "$(count)"
assert_eq "the archive-tagged snapshot survives prune" '1' "$(count --tag archive)"

# --- unattended runs: `make creds` stores encrypted credentials, the runner uses them

mkdir -p "$work/stubs"
cat >"$work/stubs/op" <<'EOF'
#!/usr/bin/env bash
# Stand-in for `op read --no-newline <ref>`: prints a value derived from the field name.
ref=${*: -1}
printf 'val-%s' "${ref##*/}"
EOF
chmod +x "$work/stubs/op"

if mk creds OP="$work/stubs/op" CRED_DIR="$work/creds"; then
    ok "make creds stores the four credentials"
else
    nok "make creds stores the four credentials" "$(make_log_tail)"
fi
for pair in restic-repository:repository aws-access-key-id:access_key_id \
    aws-secret-access-key:secret_access_key restic-password:password; do
    name=${pair%%:*}
    field=${pair#*:}
    assert_eq "creds roundtrip: $name" "val-$field" \
        "$(systemd-creds --user decrypt --name="$name" "$work/creds/$name" - 2>&1)"
    assert_absent "creds file $name holds no plaintext" "val-$field" \
        "$(cat "$work/creds/$name" 2>/dev/null)"
done
assert_eq "creds files are private" '600' "$(stat -c %a "$work/creds/restic-password" 2>/dev/null)"

# What systemd hands the service after LoadCredentialEncrypted=: plain files in a directory.
creddir=$work/credsdir
mkdir -p "$creddir"
printf '%s' "$work/repo2" >"$creddir/restic-repository"
printf 'pw2' >"$creddir/restic-password"
printf 'x' >"$creddir/aws-access-key-id"
printf 'x' >"$creddir/aws-secret-access-key"
RESTIC_REPOSITORY=$work/repo2 RESTIC_PASSWORD=pw2 restic init >/dev/null 2>&1
if CREDENTIALS_DIRECTORY=$creddir BACKUP_PATH=$home bash "$pkg/run-unattended.sh" >>"$work/make.log" 2>&1; then
    ok "the runner backs up and prunes with systemd-provided credentials"
else
    nok "the runner backs up and prunes with systemd-provided credentials" "$(make_log_tail)"
fi
assert_eq "the runner wrote to the repository named in the credential files" '1' \
    "$(RESTIC_REPOSITORY=$work/repo2 RESTIC_PASSWORD=pw2 restic snapshots --json 2>/dev/null | grep -o '"short_id"' | wc -l)"
env -u CREDENTIALS_DIRECTORY bash "$pkg/run-unattended.sh" >/dev/null 2>&1
assert_eq "the runner refuses to run outside systemd" '1' "$?"

# --- summary ---------------------------------------------------------------

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[[ $fail -eq 0 ]]
