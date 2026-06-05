# Enable Powerlevel10k instant prompt. Keep this close to the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ $- != *i* ]] && return

load_env_file() {
  local env_file="$HOME/.env"
  [[ -r "$env_file" ]] || return

  local owner mode
  owner="$(stat -f %Su "$env_file" 2>/dev/null || stat -c %U "$env_file" 2>/dev/null)"
  mode="$(stat -f %Lp "$env_file" 2>/dev/null || stat -c %a "$env_file" 2>/dev/null)"

  if [[ "$owner" == "$USER" && "$mode" -le 600 ]]; then
    set -a
    source "$env_file"
    set +a
  else
    print -u2 "Warning: ~/.env has insecure permissions or ownership"
  fi
}

load_antidote() {
  local antidote_script=""

  if (( $+commands[brew] )); then
    local brew_prefix
    brew_prefix="$(brew --prefix 2>/dev/null)"
    antidote_script="$brew_prefix/opt/antidote/share/antidote/antidote.zsh"
  fi

  [[ -r "$antidote_script" ]] || antidote_script="/usr/share/zsh-antidote/antidote.zsh"
  [[ -r "$antidote_script" ]] || antidote_script="/usr/share/antidote/antidote.zsh"
  [[ -r "$antidote_script" ]] || return

  zstyle ':antidote:home' dir "${XDG_CACHE_HOME:-$HOME/.cache}/antidote"
  source "$antidote_script"

  local plugin_file="${ZDOTDIR:-$HOME}/.zsh_plugins.txt"
  local bundle_file="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/antidote.zsh"
  mkdir -p "${bundle_file:h}"

  [[ -r "$plugin_file" ]] || return

  if [[ ! "$bundle_file" -nt "$plugin_file" ]]; then
    local tmp_bundle="${bundle_file}.tmp"
    if ! antidote bundle < "$plugin_file" >| "$tmp_bundle"; then
      rm -f "$tmp_bundle"
      return
    fi
    mv "$tmp_bundle" "$bundle_file"
  fi

  [[ -r "$bundle_file" ]] || return
  source "$bundle_file"
}

load_env_file

if [[ "$OSTYPE" == darwin* ]]; then
  if ! (( $+commands[brew] )); then
    [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    [[ -x /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
  fi

  export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
  path=(
    "$ANDROID_HOME/tools"
    "$ANDROID_HOME/tools/bin"
    "$ANDROID_HOME/platform-tools"
    "$ANDROID_HOME/emulator"
    $path
  )

  if (( $+commands[brew] )); then
    local_brew_prefix="$(brew --prefix 2>/dev/null)"
    [[ -d "$local_brew_prefix/opt/sqlite/bin" ]] && path=("$local_brew_prefix/opt/sqlite/bin" $path)
    [[ -d "$local_brew_prefix/share/android-ndk" ]] && export NDK="$local_brew_prefix/share/android-ndk"
    unset local_brew_prefix
  fi
fi

[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

if [[ -d "$HOME/.grok/bin" ]]; then
  path=("$HOME/.grok/bin" $path)
fi

if [[ -d "$HOME/.grok/completions/zsh" ]]; then
  fpath=("$HOME/.grok/completions/zsh" $fpath)
fi

autoload -Uz compinit
zstyle ':completion:*' menu select
compinit -C -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

load_antidote

bindkey -M emacs '^F' forward-char
bindkey -M viins '^F' vi-forward-char

if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

alias gw="./gradlew"

alias ls='eza --icons --git'
alias ll='eza --icons --git -la'
alias la='eza --icons --git -a'
alias lt='eza --icons --git --tree --level=2'

alias ta='tmux attach -t'
alias tl='tmux ls'
alias tn='tmux new -s'

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ddd"

[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
