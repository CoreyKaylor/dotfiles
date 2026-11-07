# Dotfiles

Personal macOS and Linux/WSL dotfiles managed with GNU Stow.

## Layout

- `zsh/`, `tmux/`, `nvim/`, `mise/`, `git/`, `lazygit/`, and `herdr/` are Stow packages that mirror files under `$HOME`.
- `Brewfile` tracks macOS packages (including `herdr` and Ghostty).
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

Ghostty should set `macos-option-as-alt = true` so `Alt-hjkl` resize reaches herdr (see Application Support Ghostty config).

## Install

```sh
./install.sh
```

On macOS this installs Homebrew if needed, runs `brew bundle install`, stows the packages, and installs Claude Code, Grok, and Codex CLI when they are missing. On Linux/WSL, install GNU Stow with the system package manager first, then run the installer.

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

[fnox](https://fnox.jdx.dev/) injects secrets as environment variables. Values live in 1Password (vault `Dev`); `fnox.toml` files hold only references like `{ provider = "op", value = "pillwise-staging/STG_DATABASE_URL" }` — item `pillwise-staging`, field `STG_DATABASE_URL`. `~/.zshrc` runs `fnox activate zsh`, so secrets load when you enter a directory that has a `fnox.toml`, including any child of it, and each `cd` prints which names changed.

fnox reads 1Password through the `op` CLI (`brew bundle` installs it). Turn on **Settings › Developer › Integrate with 1Password CLI** in the 1Password app so `op` unlocks with Touch ID. fnox batches every reference into one `op` call per directory.

### Adding a secret

```sh
fnox-set -P staging STG_NEW_TOKEN        # prompts; adds the field to the item that table already uses
fnox-set -s -i shared JIRA_API_TOKEN     # shared ~/Projects/fnox.toml, item "shared"
```

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

On Linux/WSL, install fnox with `mise use -g fnox` and sign in with `op account add`. Headless/CI should use `fnox exec` with `OP_SERVICE_ACCOUNT_TOKEN` (a service account scoped to `Dev`), not the interactive hook.

## Neovim Spikes

The production Neovim config keeps lazy.nvim. Native LSP is enabled in production. Completion and plugin-manager experiments are documented in `docs/neovim-spikes.md` and should be evaluated on separate branches before adoption.
