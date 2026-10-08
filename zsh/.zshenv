export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# fnox prints a one-line load summary on startup. That write happens during
# zsh init and trips Powerlevel10k instant prompt in new herdr panes.
export FNOX_SHELL_OUTPUT="${FNOX_SHELL_OUTPUT:-none}"

path=("$HOME/.local/bin" "$HOME/.grok/bin" "$HOME/.opencode/bin" "$HOME/.maestro/bin" "$HOME/.cargo/bin" "$HOME/.dotnet/tools" $path)

# Homebrew dotnet. Apple Silicon prefix first, then Intel / Linux Homebrew.
if [[ -z "${DOTNET_ROOT:-}" ]]; then
  for _dotnet_root in /opt/homebrew/opt/dotnet/libexec /usr/local/opt/dotnet/libexec; do
    if [[ -d "$_dotnet_root" ]]; then
      export DOTNET_ROOT="$_dotnet_root"
      break
    fi
  done
  unset _dotnet_root
fi
export DOTNET_ROLL_FORWARD="${DOTNET_ROLL_FORWARD:-Major}"

# Android SDK: Homebrew commandlinetools first, then Android Studio defaults.
# Drop a stale ANDROID_HOME that points at a missing directory (common after
# switching from Android Studio's default path to the Homebrew SDK root).
if [[ -n "${ANDROID_HOME:-}" && ! -d "$ANDROID_HOME" ]]; then
  unset ANDROID_HOME
fi
if [[ -n "${ANDROID_SDK_ROOT:-}" && ! -d "$ANDROID_SDK_ROOT" ]]; then
  unset ANDROID_SDK_ROOT
fi

if [[ -z "${ANDROID_HOME:-}" ]]; then
  for _android_sdk in \
    /opt/homebrew/share/android-commandlinetools \
    /usr/local/share/android-commandlinetools \
    "$HOME/Library/Android/sdk" \
    "$HOME/Android/Sdk"
  do
    if [[ -d "$_android_sdk" ]]; then
      export ANDROID_HOME="$_android_sdk"
      break
    fi
  done
  unset _android_sdk
fi

if [[ -n "${ANDROID_HOME:-}" ]]; then
  export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
  for _android_bin in \
    "$ANDROID_HOME/cmdline-tools/latest/bin" \
    "$ANDROID_HOME/platform-tools" \
    "$ANDROID_HOME/emulator"
  do
    [[ -d "$_android_bin" ]] && path=("$_android_bin" $path)
  done
  unset _android_bin
fi

# AVDs on this machine live under XDG config, not ~/.android/avd.
if [[ -z "${ANDROID_AVD_HOME:-}" && -d "${XDG_CONFIG_HOME}/.android/avd" ]]; then
  export ANDROID_AVD_HOME="${XDG_CONFIG_HOME}/.android/avd"
fi

# NDK via Homebrew cask symlink (share/android-ndk).
if [[ -z "${ANDROID_NDK_HOME:-}" ]]; then
  for _android_ndk in /opt/homebrew/share/android-ndk /usr/local/share/android-ndk; do
    if [[ -d "$_android_ndk" ]]; then
      export ANDROID_NDK_HOME="$_android_ndk"
      break
    fi
  done
  unset _android_ndk
fi
if [[ -n "${ANDROID_NDK_HOME:-}" ]]; then
  export NDK="${NDK:-$ANDROID_NDK_HOME}"
fi
