export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

path=("$HOME/.local/bin" "$HOME/.grok/bin" "$HOME/.opencode/bin" $path)
