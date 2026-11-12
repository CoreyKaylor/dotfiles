# fnox-set: store a secret in 1Password and reference it from a fnox.toml.
#
#   fnox-set KEY VALUE              this project (under ~/Projects) or shared
#   fnox-set -P staging KEY         a profile; prompts (hidden) or reads stdin
#   fnox-set -i ITEM KEY            the 1Password item to hold the field
#   fnox-set -V Work KEY            another vault; provider is op-<vault> (op for Dev)
#   fnox-set -s | -p | -l ...       shared, project, or project fnox.local.toml
#
# The value becomes field KEY on item ITEM in vault $FNOX_OP_VAULT (Dev),
# and the toml gets KEY = { provider = "op", value = "ITEM/KEY" }. Without
# -i, ITEM is the one the same table already references. Values reach op on
# stdin only, never argv.

fnox-set() {
  emulate -L zsh
  setopt local_options err_return no_unset pipe_fail
  set +x

  local cmd
  for cmd in fnox op jq; do
    if ! (( $+commands[$cmd] )); then
      print -u2 "fnox-set: $cmd is not installed"
      return 127
    fi
  done

  local shared="${FNOX_WORKTREE:-$HOME/Projects}"
  local vault="${FNOX_OP_VAULT:-Dev}"
  local provider="${FNOX_OP_PROVIDER:-op}"
  local mode=auto profile=default item="" dest key value stored
  local have_value=0

  while (( $# )); do
    case "$1" in
      -s|--shared) mode=shared; shift ;;
      -p|--project) mode=project; shift ;;
      -l|--local) mode=local; shift ;;
      -P|--profile) profile="${2:?fnox-set: -P needs a profile}"; shift 2 ;;
      -i|--item) item="${2:?fnox-set: -i needs an item}"; shift 2 ;;
      -V|--vault)
        vault="${2:?fnox-set: -V needs a vault}"
        if [[ "$vault" == Dev ]]; then
          provider=op
        else
          provider="op-${${vault:l}//[^a-z0-9]/-}"
        fi
        shift 2
        ;;
      -h|--help)
        print -r -- "Usage: fnox-set [-s|-p|-l] [-P PROFILE] [-i ITEM] [-V VAULT] KEY [VALUE]"
        print -r -- "  -s  $shared/fnox.toml"
        print -r -- "  -p  this project's fnox.toml"
        print -r -- "  -l  this project's fnox.local.toml"
        print -r -- "  -P  write under [profiles.PROFILE.secrets]"
        print -r -- "  -i  1Password item (default: the item this table already uses)"
        print -r -- "  -V  1Password vault (default: $vault); uses provider op-<vault>, op for Dev"
        print -r -- "  default: this project if cwd is under $shared, else shared"
        print -r -- "  VALUE may be an argument, stdin, or a hidden prompt if omitted"
        print -r -- "  vault: $vault (FNOX_OP_VAULT)"
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
    print -u2 "Usage: fnox-set [-s|-p|-l] [-P PROFILE] [-i ITEM] [-V VAULT] KEY [VALUE]"
    return 2
  fi

  key="$1"
  shift
  if [[ ! "$key" =~ '^[A-Za-z_][A-Za-z0-9_]*$' ]]; then
    print -u2 "fnox-set: not a valid variable name: $key"
    return 2
  fi
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

  if [[ -z "$item" ]]; then
    item="$(_fnox_table_item "$profile" "$provider" "$dest" "${dest:h}/fnox.toml" "${dest:h}/fnox.local.toml")"
    if [[ -z "$item" ]]; then
      print -u2 "fnox-set: no $provider references in that table yet; name the item with -i ITEM"
      return 2
    fi
  fi

  if (( ! have_value )); then
    if [[ -t 0 ]]; then
      read -rs "value?$key: "
      print -u2
    else
      value="$(cat)"
    fi
  fi
  if [[ -z "$value" ]]; then
    print -u2 "fnox-set: empty value"
    return 2
  fi

  if ! op vault get "$vault" >/dev/null 2>&1; then
    print -u2 "fnox-set: op cannot reach vault $vault (1Password unlocked? CLI integration on?)"
    return 1
  fi

  # printf is a builtin, so the value never appears in a process's argv.
  if op item get "$item" --vault "$vault" --format json >/dev/null 2>&1; then
    op item get "$item" --vault "$vault" --format json |
      jq --arg k "$key" --rawfile v <(printf '%s' "$value") '
        if any(.fields[]?; .label == $k)
        then .fields |= map(if .label == $k then .value = $v else . end)
        else .fields += [{id: $k, label: $k, type: "CONCEALED", value: $v}]
        end' |
      op item edit "$item" --vault "$vault" >/dev/null
  else
    jq -n --arg t "$item" --arg k "$key" --rawfile v <(printf '%s' "$value") '{
        title: $t, category: "SECURE_NOTE", tags: ["fnox"],
        fields: [{id: $k, label: $k, type: "CONCEALED", value: $v}]}' |
      op item create --vault "$vault" >/dev/null
    print -u2 "fnox-set: created item $item in $vault"
  fi

  stored="$(op read --no-newline "op://$vault/$item/$key")"
  if [[ "$stored" != "$value" ]]; then
    print -u2 "fnox-set: 1Password did not return the value just stored; toml left unchanged"
    return 1
  fi

  if [[ ! -e "$dest" ]]; then
    fnox --config "$dest" init --skip-wizard --non-interactive >/dev/null
  fi
  local -a pflag=()
  [[ "$profile" != default ]] && pflag=(-P "$profile")
  fnox --config "$dest" "${pflag[@]}" set --provider "$provider" -- "$key" "$item/$key" >/dev/null

  print -u2 "fnox-set: $key -> op://$vault/$item/$key, referenced in $dest"
}

# First item referenced by the given provider in a profile's table, across files.
_fnox_table_item() {
  local profile="$1" provider="$2" file section item_found
  shift 2
  if [[ "$profile" == default ]]; then
    section='secrets'
  else
    section="profiles.$profile.secrets"
  fi
  for file in "$@"; do
    [[ -r "$file" ]] || continue
    awk -v want="[$section]" -v prov="$provider" '
      /^[[:space:]]*\[/ { gsub(/[[:space:]]/, ""); cur = $0; next }
      cur == want && $0 ~ "provider *= *\"" prov "\"" &&
        match($0, /value *= *"[^"\/]+\//) {
          s = substr($0, RSTART, RLENGTH); sub(/^value *= *"/, "", s); sub(/\/$/, "", s)
          print s; exit
        }' "$file" | read -r item_found && { print -r -- "$item_found"; return 0; }
  done
  return 0
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
