# Dotfiles

Personal macOS and Linux/WSL dotfiles managed with GNU Stow.

## Layout

- `zsh/`, `tmux/`, `nvim/`, `mise/`, and `git/` are Stow packages that mirror files under `$HOME`.
- `Brewfile` tracks macOS packages.
- `justfile` provides repo tasks.
- `wallpaper/` is kept as a manual asset generator and is not stowed.
- Legacy Vim, Emacs, vendored shell plugins, Powerline fonts, and old submodules were archived in the `pre-modernization-2026-06-05` tag.

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
just shell-time
just nvim-startup
```

## Secrets

Secrets stay out of this repository. Do not commit plaintext secrets, encrypted secret blobs, or generated secret files. The shell may source a local `~/.env` only when it is owned by the current user and has permissions no broader than `0600`.

## Neovim Spikes

The production Neovim config keeps lazy.nvim. Native LSP is enabled in production. Completion and plugin-manager experiments are documented in `docs/neovim-spikes.md` and should be evaluated on separate branches before adoption.
