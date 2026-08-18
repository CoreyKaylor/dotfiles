# fnox-set: store a keychain secret without the long fnox -c … pipeline.
#
#   fnox-set KEY VALUE            this project (under ~/Projects) or shared
#   fnox-set -s KEY VALUE         always ~/Projects/fnox.toml
#   fnox-set -p KEY VALUE         this project's fnox.toml
#   fnox-set -l KEY VALUE         this project's fnox.local.toml
#   fnox-set KEY                  prompt (hidden) or read stdin if piped

fnox-set() {
  emulate -L zsh
  setopt local_options err_return no_unset
  set +x

  if ! (( $+commands[fnox] )); then
    print -u2 "fnox-set: fnox is not installed"
    return 127
  fi

  local shared="${FNOX_WORKTREE:-$HOME/Projects}"
  local mode=auto dest key value
  local have_value=0

  while (( $# )); do
    case "$1" in
      -s|--shared) mode=shared; shift ;;
      -p|--project) mode=project; shift ;;
      -l|--local) mode=local; shift ;;
      -h|--help)
        print -r -- "Usage: fnox-set [-s|-p|-l] KEY [VALUE]"
        print -r -- "  -s  $shared/fnox.toml"
        print -r -- "  -p  this project's fnox.toml"
        print -r -- "  -l  this project's fnox.local.toml"
        print -r -- "  default: this project if cwd is under $shared, else shared"
        print -r -- "  VALUE may be an argument, stdin, or a hidden prompt if omitted"
        return 0
        ;;
      --) shift; break ;;
      -*)
        print -u2 "fnox-set: unknown option: $1"
        return 2
        ;;
      *) break ;;
    esac
  done

  if (( $# < 1 )); then
    print -u2 "Usage: fnox-set [-s|-p|-l] KEY [VALUE]"
    return 2
  fi

  key="$1"
  shift
  if (( $# )); then
    value="$*"
    have_value=1
  fi

  if [[ "$mode" == auto ]]; then
    if [[ "$PWD" == "$shared"/* ]]; then
      mode=project
    else
      mode=shared
    fi
  fi

  case "$mode" in
    shared) dest="$shared/fnox.toml" ;;
    project|local)
      dest="$(_fnox_project_root "$shared")/fnox.toml"
      [[ "$mode" == local ]] && dest="${dest:h}/fnox.local.toml"
      ;;
  esac

  if [[ ! -e "$dest" ]]; then
    fnox --config "$dest" init --skip-wizard --non-interactive
  fi

  print -u2 "fnox-set: $key -> $dest"
  if (( have_value )); then
    printf '%s' "$value" | fnox --config "$dest" set --provider keychain -- "$key"
  else
    fnox --config "$dest" set --provider keychain -- "$key"
  fi
}

_fnox_project_root() {
  local shared="$1" git_root rest

  if git_root="$(git rev-parse --show-toplevel 2>/dev/null)" &&
    [[ "$git_root" == "$shared"/* ]]; then
    print -r -- "$git_root"
    return
  fi

  if [[ "$PWD" == "$shared"/* ]]; then
    rest="${PWD#$shared/}"
    print -r -- "$shared/${rest%%/*}"
    return
  fi

  print -u2 "fnox-set: not inside $shared; use -s for the shared store"
  return 1
}
