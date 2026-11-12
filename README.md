# Dotfiles

Personal macOS and Linux/WSL dotfiles managed with GNU Stow.

## Layout

- `zsh/`, `tmux/`, `nvim/`, `mise/`, `git/`, `lazygit/`, `herdr/`, `ghostty/`, and `ssh/` are Stow packages that mirror files under `$HOME`. `omarchy/` is one too, stowed only on Omarchy.
- `Brewfile` tracks macOS packages (including `herdr` and Ghostty); `Archfile` is the Arch Linux counterpart.
- `justfile` provides repo tasks.
- `fnox/` is helper scripts. It is not stowed; secret values stay out of this repo.
- `wallpaper/` is kept as a manual asset generator and is not stowed.
- Legacy Vim, Emacs, vendored shell plugins, Powerline fonts, and old submodules were archived in the `pre-modernization-2026-06-05` tag.

### Herdr

Herdr config lives at `herdr/.config/herdr/config.toml` (prefix `ctrl+a`, tmux-like panes/tabs/workspaces). Seamless `Ctrl-hjkl` / `Alt-hjkl` between nvim and herdr panes uses the [herdr-splits](https://github.com/lmilojevicc/herdr-splits.nvim) plugin (installed by `./install.sh` when `herdr` is available).

```sh
herdr                                      # attach / start
herdr config check                         # validate config.toml
herdr server reload-config                 # apply after edits
herdr plugin install lmilojevicc/herdr-splits.nvim
prefix+?                                   # in-session keybind help
```

### Ghostty

Shared Ghostty settings live in `ghostty/.config/ghostty/dotfiles.conf` (including `macos-option-as-alt = true`, so `Alt-hjkl` resize reaches herdr). `~/.config/ghostty/config` itself stays machine-local, since Omarchy's font and text-size commands rewrite it in place. `install.sh` appends `config-file = ?dotfiles.conf` to it. The included file loads last and wins, so keep `font-family` and `font-size` in the local file. On macOS, Ghostty also reads `~/Library/Application Support/com.mitchellh.ghostty/config` after the XDG config, so remove settings there that should come from the repo.

### Omarchy

`omarchy/` holds only what differs from Omarchy's defaults: `hypr/dotfiles.lua` (Dell 4K above the laptop at 1.333333 scale, Caps/Ctrl swap, Mac-like trackpad and gestures, workspace slide), `omarchy/shell.json` (bar, dock with Ghostty pinned, world clocks), the `workspace-background` shell plugin and the owe `theme-set` hook. Omarchy's own `hypr/*.lua` files stay stock and machine-local, so its update migrations can keep editing them. `install.sh` also makes Ghostty the default terminal (Omarchy ships foot) and adds `require("hypr.dotfiles")` to `~/.config/hypr/hyprland.lua`, just above Omarchy's runtime toggles, so these settings load after Omarchy's defaults and a toggle still wins. `just omarchy-drift` reports a missing require, a broken link or an unsaved `shell.json`; rerun `./install.sh` to fix the first two.

`shell.json` is copied, not stowed, because Omarchy saves it by renaming a new file over it, which would replace a symlink. Omarchy uses it in place of its defaults rather than merging, so it has to be the complete file. `install.sh` only replaces a missing or stock copy. After changing the bar or dock, run `just omarchy-save` to bring the live file back into the repo. `uninstall.sh` leaves real copies behind, since Hyprland fails to load if `dotfiles.lua` is missing.

## Install

```sh
./install.sh
```

On macOS this installs Homebrew if needed, runs `brew bundle install`, stows the packages, runs `mise install`, and installs Claude Code, Grok, and Codex CLI when they are missing.

On Arch (including Omarchy) it installs the `Archfile` with `yay`/`paru`, runs `mise install` for the global tools (flyctl, wrangler, stripe, rust and the rest in `mise/.config/mise/config.toml`, plus fnox from `conf.d/fnox.toml`, since its AUR package is x86_64 only), enables `docker` and adds you to the `docker` group, reminds you to create the per-machine `~/.config/fnox/config.toml` (`[providers.op]`, `type = "1password"`, `vault = "Dev"`), installs Omarchy's lazy mise AI CLIs (Grok, Claude, Codex) up front, installs Grok Bot (`grok-bot-bin` from the AUR on x86_64, the official AppImage unpacked to `~/.local/share/grok-bot` on arm64), enables `tailscaled`, and offers to `chsh` to zsh. Run it from a terminal, since sudo and chsh prompt. Existing files that would block stow (Omarchy's LazyVim, lazygit, herdr and `~/.config/git/config`) are moved to `~/.dotfiles-backup/<timestamp>/` first. Reruns leave files that already link into the repo alone. Clone over HTTPS the first time; switch the remote to SSH once the 1Password agent is on.

On other Linux/WSL, install GNU Stow with the system package manager first, then run the installer.

The AI CLI installers are vendor-managed and keep authentication/state outside this repository:

- Claude Code: `~/.claude/` and `~/.local/bin/claude`
- Grok: `~/.grok/`
- Codex: `~/.codex/` and `~/.local/bin/codex`

Useful commands:

```sh
just install
just check
just secrets-worktree ~/Projects
just secrets-docs pull
just shell-time
just nvim-startup
```

## Secrets

Secrets stay out of this repository. Do not commit plaintext secrets, encrypted secret blobs, or generated secret files.

[fnox](https://fnox.jdx.dev/) injects secrets as environment variables. Values live in 1Password (vault `Dev`); `fnox.toml` files hold only references like `{ provider = "op", value = "myapp-staging/DATABASE_URL" }` — item `myapp-staging`, field `DATABASE_URL`. `~/.zshrc` runs `fnox activate zsh`, so secrets load when you enter a directory that has a `fnox.toml`, including any child of it, and each `cd` prints which names changed.

fnox reads 1Password through the `op` CLI (`brew bundle` installs it). Turn on **Settings › Developer › Integrate with 1Password CLI** in the 1Password app so `op` unlocks with Touch ID. fnox batches every reference into one `op` call per directory.

### Adding a secret

```sh
fnox-set -P staging STG_NEW_TOKEN        # prompts; adds the field to the item that table already uses
fnox-set -s -i shared JIRA_API_TOKEN     # shared ~/Projects/fnox.toml, item "shared"
fnox-set -V Work -i snowflake SNOWFLAKE_PASSWORD   # another vault; reference uses provider op-work
```

Each vault needs a provider in `~/.config/fnox/config.toml`: `op` for `Dev`, `op-<vault, lowercased>` for the rest (`Work` is `op-work`). A single `fnox.toml` can mix them, and the provider on each reference decides which vault the value comes from.

`fnox-set` writes the value to 1Password on stdin (never argv), reads it back, then adds the reference to the right `fnox.toml`. `fnox set` alone cannot write to 1Password.

### Shared CLI secrets (Jira, GitHub, …)

Put one `fnox.toml` at a work-tree root, not in every project and not at `$HOME`:

```text
~/Projects/fnox.toml     # JIRA_API_TOKEN, GITHUB_TOKEN, …
~/Projects/crowded/      # inherits
~/Projects/personal/     # inherits
```

`cd ~/Projects/anything` then gets those variables automatically. A project can add its own `fnox.toml` for extra keys. `fnox exec -- jira …` works from those trees without the shell hook.

### fnox files outside a repo

Some `fnox.toml` files sit in directories that are not git repos (for example `~/Projects/fnox.local.toml`). They hold references only and are kept as 1Password documents tagged `fnox-config`:

```sh
just secrets-docs push ~/Projects/fnox.local.toml   # after editing one
just secrets-docs pull                              # on a new machine; never overwrites
```

### New machine

```sh
brew bundle                        # fnox, 1password-cli
# 1Password app: sign in, enable CLI integration
just secrets-worktree ~/Projects   # adds the "op" provider to ~/.config/fnox/config.toml
just secrets-docs pull
cd ~/Projects/... && fnox list
```

On Linux, the 1Password app's SSH agent socket is `~/.1password/agent.sock` (macOS gets a symlink at the same path from `install.sh`), and commit signing uses `/opt/1Password/op-ssh-sign`. Turn on **Settings › Developer › Use the SSH agent** and **Integrate with 1Password CLI**. Without the desktop app (WSL, servers), sign in with `op account add`. Headless/CI should use `fnox exec` with `OP_SERVICE_ACCOUNT_TOKEN` (a service account scoped to `Dev`), not the interactive hook.

## Neovim Spikes

The production Neovim config keeps lazy.nvim. Native LSP is enabled in production. Completion and plugin-manager experiments are documented in `docs/neovim-spikes.md` and should be evaluated on separate branches before adoption.
