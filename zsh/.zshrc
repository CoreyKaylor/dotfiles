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

if [[ -d "$HOME/.grok/completions/zsh" ]]; then
  fpath=("$HOME/.grok/completions/zsh" $fpath)
fi

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=50000
SAVEHIST=50000
mkdir -p "${HISTFILE:h}"

setopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt inc_append_history
setopt share_history
fc -R "$HISTFILE" 2>/dev/null || true

autoload -Uz compinit
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zstyle ':completion:*' menu select
compinit -C -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

load_antidote

fzf-history-select() {
  (( $+commands[fzf] )) || {
    zle redisplay
    return
  }

  zle -I

  local selected
  selected="$(fc -rl 1 | fzf --height 40% --reverse --query "$LBUFFER")" || {
    zle redisplay
    return
  }

  if [[ "$selected" =~ '^[[:space:]]*[0-9]+[[:space:]]+(.*)$' ]]; then
    BUFFER="$match[1]"
    CURSOR="${#BUFFER}"
  fi

  zle redisplay
}

fzf-file-select() {
  (( $+commands[fzf] )) || {
    zle redisplay
    return
  }

  zle -I

  local selected item
  if (( $+commands[fd] )); then
    selected="$(fd --hidden --follow --exclude .git . | fzf --height 40% --reverse --multi)" || {
      zle redisplay
      return
    }
  else
    selected="$(find . -path './.git' -prune -o -print | sed 's#^\./##' | fzf --height 40% --reverse --multi)" || {
      zle redisplay
      return
    }
  fi

  while IFS= read -r item; do
    [[ -n "$item" ]] && LBUFFER+="${(q)item} "
  done <<< "$selected"

  zle redisplay
}

fzf-cd-select() {
  (( $+commands[fzf] )) || {
    zle redisplay
    return
  }

  zle -I

  local selected
  if (( $+commands[fd] )); then
    selected="$(fd --hidden --follow --exclude .git --type d . | fzf --height 40% --reverse)" || {
      zle redisplay
      return
    }
  else
    selected="$(find . -path './.git' -prune -o -type d -print | sed 's#^\./##' | fzf --height 40% --reverse)" || {
      zle redisplay
      return
    }
  fi

  [[ -n "$selected" ]] && cd -- "$selected"
  zle reset-prompt
}

zle -N fzf-history-select
zle -N fzf-file-select
zle -N fzf-cd-select

bindkey -M emacs '^F' forward-char
bindkey -M viins '^F' vi-forward-char
bindkey -M emacs '^R' fzf-history-select
bindkey -M viins '^R' fzf-history-select
bindkey -M emacs '^T' fzf-file-select
bindkey -M viins '^T' fzf-file-select
bindkey -M emacs '^[c' fzf-cd-select
bindkey -M viins '^[c' fzf-cd-select
bindkey -M emacs '^[[A' up-line-or-beginning-search
bindkey -M emacs '^[[B' down-line-or-beginning-search
bindkey -M emacs '^[OA' up-line-or-beginning-search
bindkey -M emacs '^[OB' down-line-or-beginning-search
bindkey -M viins '^[[A' up-line-or-beginning-search
bindkey -M viins '^[[B' down-line-or-beginning-search
bindkey -M viins '^[OA' up-line-or-beginning-search
bindkey -M viins '^[OB' down-line-or-beginning-search

if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
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
