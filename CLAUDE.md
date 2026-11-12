# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles managed with **GNU Stow**. Each top-level directory is a stow package that maps to `~/.config/{app}/` (or `~/` for git).

**`fedora-files` is the live branch** and the only one that is maintained. It runs Hyprland with the Noctalia shell on Fedora. `main` (Sway, Alacritty, Rofi, Waybar) and `arch-files` (Arch + Waybar/Mako/Fuzzel) are archival history of earlier setups; do not clean or update them. Removed configs stay recoverable from those branches and from earlier `fedora-files` commits.

Packages on this branch: `bin`, `doom`, `fish`, `ghostty`, `git`, `hyprland`, `hyprmoncfg`, `hyprwhspr`, `kanata`, `mise`, `noctalia`, `nvim`, `portals`, `systemd`, `vscode`.

## Stow Layout

Each directory follows the pattern `{package}/.config/{app}/...` so that `stow -R -t $HOME {package}` creates the correct symlinks. `{app}` is the target directory name, which is not always the package name: `hyprland` maps to `.config/hypr`, `portals` to `.config/xdg-desktop-portal` and `vscode` to `.config/Code/User`. The `git/` package is an exception — it places `.gitconfig` directly in `$HOME` and the global ignore list at `.config/git/ignore` (the path Git actually reads; `~/.gitignore` is not read).

When adding a new config, mirror the target filesystem path inside a new top-level directory.

```bash
stow -n -v -R -t $HOME {package}   # dry run first
stow -R -t $HOME {package}         # restow
stow -D -t $HOME {package}         # unstow
```

There is no setup script or package list on this branch; Fedora setup is manual.

## What Is Tracked

Rule: a config stays only if the live Hyprland config, the shell config, or a binary that is launched references it. Installed alone is not enough.

- **Editors:** Doom Emacs (`doom/`) is the main editor and is launched by Hyprland (`emacsclient`); Neovim (`nvim/`, minimal vim.pack + mini.nvim) is `$EDITOR` for terminal and git use; VS Code (`vscode/`) is used for Jupyter notebooks.
- **Desktop:** Hyprland (`hyprland/`) with the Noctalia v5 shell, which provides the bar, launcher, clipboard, notifications and lock screen through `noctalia msg ...`. Terminal is Ghostty (`ghostty/`). `portals/` sets the xdg-desktop-portal backends.
- **Shell and tools:** Fish (`fish/`), `mise/`, `git/`.
- **Theme:** Catppuccin (Mocha dark / Latte light) in Ghostty, Doom, VS Code and Noctalia.

## Hyprland

- `hyprland.lua` is the Lua config and must stay **self-contained**: it may not `require` a module that is not tracked. The Noctalia-generated `~/.config/hypr/noctalia/noctalia-colors.lua` (not tracked) is loaded with `pcall` so a missing file only means default borders.
- Monitor layout is owned by **hyprmoncfg**, not by `hyprland.lua`. Profiles are hardware-keyed JSON in `hyprmoncfg/.config/hyprmoncfg/profiles/` (stow package `hyprmoncfg`); `hyprmoncfgd` (systemd unit in the `systemd` package, bound to `hyprland-session.target`) applies the best match on hotplug and lid changes. hyprmoncfg writes `~/.config/hypr/hyprmoncfg-monitors.lua` and loads it last from `hyprland.lua`; that generated file is **not tracked**. Unknown displays are extended to the right of the matching profile, so a new projector works without config. Capture a setup with `hyprmoncfg save <name>` or arrange it in `hyprmoncfg` (TUI). Committed profiles are `home` and `mobile`; there is no `office` profile yet, so the office desk falls back to `mobile` (laptop panel + extra displays extended right) until one is captured there.
- `hyprland.lua` keeps only the catch-all `monitor` rule (covers the instant before the generated file loads) and the workspace-move binds. Do not reintroduce per-output monitor rules there: anything loaded after `hyprmoncfg-monitors.lua` overrides the applied profile, and `hyprmoncfg doctor` reports that.
- `hypr/scripts/power-policy.sh` holds the docked/undocked policy: the lid switch calls it with `on` (docked: no-op; undocked: lock and suspend), and the Noctalia idle behavior calls it with `idle` at 15 min (docked: no-op; undocked: suspend, the screen is already locked). **Docked means AC online and the lid closed** — never monitor presence, because the home OLED disconnects when it powers off. `--dry-run` reports the decision, and `POWER_POLICY_AC_ONLINE` / `POWER_POLICY_LID_STATE` override the readings for testing.
- The lid switch bind no longer touches the layout: hyprmoncfgd reads lid state via UPower and forces the internal panel off when docked with an external output showing a picture.
- Validate a config with `Hyprland --verify-config -c <file>`, but run it with a private runtime dir: `env -u HYPRLAND_INSTANCE_SIGNATURE -u WAYLAND_DISPLAY XDG_RUNTIME_DIR=$(mktemp -d) Hyprland --verify-config -c <file>` (the dir must be mode 700). Inside a live session it otherwise cannot bind its IPC socket and never evaluates the config. Success prints `config ok`.
- `~/.config/hypr/hyprland.lua` is a symlink to the repo file and Hyprland may auto-reload when it changes.

## Noctalia

- Noctalia builds its config from every `*.toml` in `~/.config/noctalia/` (tracked: `noctalia/.config/noctalia/config.toml`) and then the Settings UI's `~/.local/state/noctalia/settings.toml` on top. The state file overrides the tracked one. `~/.config/noctalia` is a directory-level symlink to the repo directory, so any `*.toml` added there is live immediately.
- `config.toml` is a pruned baseline from `noctalia config export`. To refresh it after changing settings in the UI, re-export and drop the machine-specific tables: `lockscreen_widgets` (per-monitor pixel layout), `wallpaper` (the daily wallpaper path changes) and `location`. Check it with `noctalia config validate <file>`.
- Never track anything under `~/.local/state/noctalia/` (clipboard history, notification history, credential-migration state).

## Session Units

Session processes are systemd user units in `systemd/`, enabled with
`WantedBy=hyprland-session.target` and started with the session (at boot with
autologin, otherwise at login): `noctalia.service`, `emacs.service`,
`nm-applet.service` and `1password.service`. `piper-tts.service` and
`kanata.service` are the exceptions — they are background services on
`default.target`.

This session does **not** start `xdg-desktop-autostart.target`, so entries in
`~/.config/autostart` (including the one 1Password writes itself) do nothing.
Add a tracked unit under `systemd/`, `stow -R systemd`, then
`systemctl --user enable <unit>`; the enable symlink lives in
`~/.config/systemd/user/hyprland-session.target.wants/` and is not tracked.

## Keyboard

Home-row mods are done here, not in UHK Agent: firmware mod-taps and OS
mod-taps stack into double-modifier garbage. The UHK keeps layout/nav layers;
kanata owns `a s d f / j k l ;` only.

- `kanata/.config/kanata/kanata.kbd` is the config; `kanata.service` (in
  `systemd/`) runs it on `default.target` as the normal user. Three untracked
  host steps are required, because Fedora's `/dev/uinput` is `root:root 0600`
  and the module is not loaded at boot:
  `usermod -aG input $USER` (then a full re-login — a `systemctl --user`
  reexec does not pick up new groups), `/etc/modules-load.d/uinput.conf`
  containing `uinput`, and a udev rule
  `KERNEL=="uinput", GROUP="input", MODE="0660"`. hyprwhspr ships that same
  rule as `99-hyprwhspr-uinput.rules`; without the module entry the device
  never appears at boot and kanata dies with `Permission denied (os error 13)`
  in a restart loop.
- `tap-hold-release-keys` with explicit per-hand key lists is what keeps
  typing safe: a same-hand key during a hold resolves as a tap, an
  opposite-hand press+release resolves the modifier early. The lists must
  cover every key used while typing or the protection has holes.
- Terra ships kanata 1.11.0. `defhands`, `tap-hold-opposite-hand` and the
  `tap-hold-require-prior-idle` defcfg option are 1.12+ and will fail
  `--check` on this version.
- Validate before restarting: `kanata --check -c ~/.config/kanata/kanata.kbd`,
  then `systemctl --user restart kanata`. A dead kanata releases the grabbed
  devices, so losing it costs the mods, not the keyboard.

## Speech

- **Read-aloud:** `bin/.local/bin/read-selection.sh` speaks the PRIMARY selection
  (clipboard as fallback) with Piper. It strips markdown, ANSI escapes, box
  drawing and fenced code, splits the text into sentence chunks and streams them,
  so audio starts after the first sentence instead of after the whole selection.
  Bound to `Super+R` in `hyprland.lua` with an absolute path, because
  `~/.local/bin` is not guaranteed on Hyprland's PATH. `Super+Shift+R` runs it
  with `--stop`, which terminates the current read (a new read also stops the
  previous one, so presses never stack).
- **Piper server:** `systemd/.config/systemd/user/piper-tts.service` keeps the
  voice model loaded, because the CLI reloads it on every run (~3s). The script
  POSTs to `http://127.0.0.1:5000/synthesize` and falls back to the CLI when the
  unit is down. Enable with `systemctl --user enable --now piper-tts.service`.
- Runtime deps: `piper` (below), `paplay` (`pulseaudio-utils`), `jq`, `curl`,
  `wl-paste` (`wl-clipboard`). A missing player or piper raises a desktop
  notification instead of failing silently.
- Install (not tracked): `uv tool install 'piper-tts[http]'`; voices live in
  `~/.local/share/piper` and are downloaded with
  `~/.local/share/uv/tools/piper-tts/bin/python -m piper.download_voices <voice> --data-dir ~/.local/share/piper`.
  Default voice is `en_US-ryan-high`; override with `PIPER_VOICE` (the voice must
  exist in the data dir), `PIPER_DATA_DIR` or `PIPER_URL`. Portuguese needs a
  `pt_BR` voice; there is no language detection.
- Tests: `bash tests/read-selection.sh`. `tests/` is a plain directory, not a
  stow package.
- **Dictation:** `bin/.local/bin/dictation.sh` maps Hyprland key events to
  `hyprwhspr record start|release|cancel`. Bound to `Super+M` press and release
  (`{ release = true }`) for push-to-talk, and `Super+Escape` to discard a
  recording. hyprwhspr runs with `external_bindings = true`, so Hyprland owns the
  keys and the service does not grab keyboards; a missing CLI or a failed start
  raises a notification instead of failing silently.
- **hyprwhspr:** installed as a managed release under `~/.local/share/hyprwhspr`
  (not tracked; update with `hyprwhspr update`). Config is stowed from
  `hyprwhspr/.config/hyprwhspr/config.json`: whisper.cpp via pywhispercpp with the
  Vulkan wheel, model `large-v3-turbo`, `inject_mode: wtype`, auto language
  detection for English and Portuguese, and `whisper_prompt_pt` nudging European
  Portuguese. Models live in `~/.local/share/pywhispercpp/models` (untracked,
  1.6 GB). The upstream dependency script does **not** install `wtype`; install it
  separately. `vulkaninfo` (`vulkan-tools`) is what lets backend auto-detection
  find the AMD iGPU — without it setup falls back to CPU faster-whisper.
- **Noctalia widget:** `hyprwhspr noctalia install` installs `goodroot/noctwhspr`
  and registers the mic-OSD theme template. The widget is placed in the tracked
  Noctalia config: `goodroot/noctwhspr` in `[plugins] enabled` and
  `goodroot/noctwhspr:status` in `bar.default.end`. Never track the plugin files
  or the generated `templates/noctwhspr-mic-osd.css`.
- Install (not tracked): `sudo dnf install wtype vulkan-tools`, then
  `HYPRWHSPR_RELEASE_BOOTSTRAP=1 bash install.sh` and
  `hyprwhspr setup auto --backend vulkan --model large-v3-turbo --hypr-bindings`.
  Latency is ~3 s for a short utterance on the Vulkan backend (auto-detect
  dominates); CPU faster-whisper was ~3x realtime and is the fallback.
- Tests: `bash tests/dictation.sh`.

## Fish

Only `config.fish` and `fish_plugins` (the Fisher manifest) are tracked. Everything under `functions/`, `conf.d/` and `completions/` is installed by Fisher (Pure prompt, plugin-git) or generated by `mise`/`bun`/`poetry`, and `fish_variables` is machine-local state; all of these are gitignored. The fzf key bindings come from `fzf --fish | source`, not a tracked file. `PATH` entries are added with `fish_add_path -g` (idempotent), never by prepending to `$PATH`.

On a new machine, bootstrap Fisher first (`fisher.fish` itself is not in the repo), then run `fisher update` to install what `fish_plugins` lists. Regenerate the `mise`, `bun` and `poetry` completions with each tool's own completion command.

## Git

- `~/.gitconfig` is stowed from `git/.gitconfig`; the global ignore list is `git/.config/git/ignore`, containing `**/.claude/settings.local.json` and `mise.local.toml`.
- Defaults: `pull.rebase`, `push.autoSetupRemote`, `rebase.autoSquash` (used by `/ship`), `rebase.updateRefs`, `merge.conflictStyle = zdiff3`, `diff.algorithm = histogram`, `rerere.enabled`, `commit.verbose`.
- Per-client overrides come from `includeIf` blocks for `~/Documents/projects/**` and `~/Documents/projects/AIH/**`. Add a working-tree `.gitconfig` there, not in this repo.
- Commit signing is available through 1Password (`op-ssh-sign`) but left commented out until an employer requires it.

## Working with This Repo

- Always use `stow -R` (restow) and dry-run with `stow -n -v` first.
- A real file at a target path makes stow abort. Move it aside (do not delete it) and compare after stowing.
- **Check whether a live path is a symlink with `test -L` / `readlink -f` before trusting any content comparison.** `cmp` or `diff` through a stow link compares the repo file with itself, and deleting the repo copy then leaves the live link dangling.
- Do not track machine state or generated files (`fish_variables`, `~/.local/state/noctalia`, Fisher-installed files, `hypr/noctalia/noctalia-colors.lua`).
- `.agents/` holds agent working state and is ignored except `.gitignore`, `conventions.md` and `review.md`.
