#!/usr/bin/env bash
# Tests for bin/.local/bin/dictation.sh and the dictation wiring.
# Dependency-free on purpose: bash + coreutils + jq, no bats.
# Run: bash tests/dictation.sh
set -uo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
script=$repo/bin/.local/bin/dictation.sh
config=$repo/hyprwhspr/.config/hyprwhspr/config.json
lua=$repo/hyprland/.config/hypr/hyprland.lua
noctalia=$repo/noctalia/.config/noctalia/config.toml

if [[ ! -f $script ]]; then
    echo "FAIL $script is missing" >&2
    exit 1
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/stubs" "$work/out" "$work/home/.local/bin" "$work/empty"
ln -sf "$(command -v bash)" "$work/empty/bash"

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
    if [[ $3 == *"$2"* ]]; then ok "$1"; else nok "$1" "[$2] not in [$3]"; fi
}
assert_file() { # name path
    if [[ -f $2 ]]; then ok "$1"; else nok "$1" "$2 is missing"; fi
}

stub() { # name body
    printf '#!/usr/bin/env bash\n%s\n' "$2" >"$work/stubs/$1"
    chmod +x "$work/stubs/$1"
}

# shellcheck disable=SC2016 # stub bodies expand at run time, not now
stub hyprwhspr 'printf "%s\n" "$*" >>"$OUT/calls"
exit "${STUB_RC:-0}"'
# shellcheck disable=SC2016
stub notify-send 'printf "%s\n" "$*" >>"$OUT/notify"'

reset_out() { rm -f "$work"/out/*; }

# Run the script with stubs on PATH. HYPRWHSPR_BIN is set unless the test
# clears it to exercise the resolution order.
call() { # [env assignments...] -- args...
    local envs=()
    while [[ $1 != -- ]]; do envs+=("$1"); shift; done
    shift
    (export OUT=$work/out HOME=$work/home
        PATH="$work/stubs:$PATH"
        exec env "${envs[@]}" "$script" "$@") </dev/null
}

last_call() { cat "$work/out/calls" 2>/dev/null; }
last_notify() { cat "$work/out/notify" 2>/dev/null; }

# --- Config file -----------------------------------------------------------
assert_file "tracked hyprwhspr config exists" "$config"

if jq -e . "$config" >/dev/null 2>&1; then
    ok "config is valid JSON"
else
    nok "config is valid JSON"
fi

cfg() { jq -r "$1" "$config" 2>/dev/null; }
assert_eq "external bindings enabled" "true" "$(cfg '.external_bindings')"
assert_eq "recording mode is push-to-talk" "push_to_talk" "$(cfg '.recording_mode')"
assert_eq "injection is wtype" "wtype" "$(cfg '.inject_mode')"
assert_eq "model is large-v3-turbo" "large-v3-turbo" "$(cfg '.model')"
if [[ -n $(cfg '.whisper_prompt_pt') && $(cfg '.whisper_prompt_pt') != null ]]; then
    ok "Portuguese prompt is set"
else
    nok "Portuguese prompt is set"
fi

# --- Wiring ----------------------------------------------------------------
assert_file "hyprland.lua exists" "$lua"
binds=$(grep -c 'dictation\.sh' "$lua" 2>/dev/null || true)
assert_eq "three dictation binds wired" "3" "$binds"
if grep -q 'release = true' "$lua" 2>/dev/null; then
    ok "push-to-talk release bind present"
else
    nok "push-to-talk release bind present"
fi
if grep -q 'goodroot/noctwhspr:status' "$noctalia" 2>/dev/null; then
    ok "noctwhspr widget placed in the bar"
else
    nok "noctwhspr widget placed in the bar"
fi

# --- Action mapping --------------------------------------------------------
reset_out
call HYPRWHSPR_BIN="$work/stubs/hyprwhspr" -- start
assert_eq "start maps to record start" "record start" "$(last_call)"

reset_out
call HYPRWHSPR_BIN="$work/stubs/hyprwhspr" -- release
assert_eq "release maps to record release" "record release" "$(last_call)"

reset_out
call HYPRWHSPR_BIN="$work/stubs/hyprwhspr" -- cancel
assert_eq "cancel maps to record cancel" "record cancel" "$(last_call)"

reset_out
call HYPRWHSPR_BIN="$work/stubs/hyprwhspr" -- toggle
assert_eq "toggle maps to record toggle" "record toggle" "$(last_call)"

reset_out
call HYPRWHSPR_BIN="$work/stubs/hyprwhspr" -- start --lang pt
assert_eq "per-recording language passes through" "record start --lang pt" "$(last_call)"

# --- Errors ----------------------------------------------------------------
reset_out
call HYPRWHSPR_BIN="$work/stubs/hyprwhspr" -- frobnicate
rc=$?
assert_eq "unknown action exits 2" "2" "$rc"

reset_out
call HYPRWHSPR_BIN="$work/stubs/hyprwhspr" --
rc=$?
assert_eq "no action exits 2" "2" "$rc"

reset_out
call HYPRWHSPR_BIN="$work/nonexistent" HOME="$work/no-home" PATH="$work/empty" -- start
rc=$?
assert_eq "missing CLI exits 1" "1" "$rc"

reset_out
call HYPRWHSPR_BIN="$work/stubs/hyprwhspr" STUB_RC=1 -- start
rc=$?
assert_eq "failed start exits 1" "1" "$rc"
assert_contains "failed start notifies" "hyprwhspr" "$(last_notify)"

reset_out
call HYPRWHSPR_BIN="$work/stubs/hyprwhspr" STUB_RC=1 -- release
rc=$?
assert_eq "failed release stays quiet" "" "$(last_notify)"

reset_out
call HYPRWHSPR_BIN="$work/stubs/hyprwhspr" STUB_RC=1 -- cancel
rc=$?
assert_eq "failed cancel exits 1" "1" "$rc"
assert_contains "failed cancel notifies" "hyprwhspr" "$(last_notify)"

# --- Binary resolution -----------------------------------------------------
# A stub in ~/.local/bin that records a distinct marker.
# shellcheck disable=SC2016 # stub body expands at run time, not now
printf '#!/usr/bin/env bash\nprintf "localbin %%s\\n" "$*" >>"$OUT/calls"\n' \
    >"$work/home/.local/bin/hyprwhspr"
chmod +x "$work/home/.local/bin/hyprwhspr"

reset_out
call HYPRWHSPR_BIN="$work/stubs/hyprwhspr" -- start
assert_eq "HYPRWHSPR_BIN wins over ~/.local/bin" "record start" "$(last_call)"

reset_out
call HOME="$work/home" -- start
assert_contains "local bin is used when the env override is unset" "localbin" "$(last_call)"

reset_out
call HOME="$work/no-home" -- start
assert_eq "PATH is the last resort" "record start" "$(last_call)"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
((fail == 0))
