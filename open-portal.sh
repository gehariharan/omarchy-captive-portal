#!/bin/bash
# Opens a captive portal sign-in page

url="${1:?usage: open-portal.sh <url>}"

if [[ ! ${url,,} =~ ^https?://[^[:cntrl:]]{1,2000}$ ]] || [[ $url == *']==]'* ]]; then
  echo "refusing to open untrusted url: $url" >&2
  exit 1
fi

profile="$(mktemp -d "${XDG_RUNTIME_DIR:-/tmp}/omarchy-captive-portal.XXXXXX")" || exit 1

app_args=(
  --app="$url"
  --user-data-dir="$profile"
  --profile-directory=omarchy-captive
  --incognito
  --no-first-run
  --no-default-browser-check
)

gecko_args=(
  --profile "$profile"
  --no-remote
  --private-window "$url"
)

if command -v chromium >/dev/null; then
  set -- chromium "${app_args[@]}"
else
  case "$(omarchy-default-browser 2>/dev/null)" in
    chrome)       set -- google-chrome-stable "${app_args[@]}" ;;
    brave)        set -- brave "${app_args[@]}" ;;
    brave-origin) set -- brave-origin "${app_args[@]}" ;;
    edge)         set -- microsoft-edge-stable "${app_args[@]}" ;;
    firefox)      set -- firefox "${gecko_args[@]}" ;;
    zen)          set -- zen-browser "${gecko_args[@]}" ;;
    *)            set -- xdg-open "$url" ;;
  esac
fi

command -v "$1" >/dev/null || { echo "no browser available to open $url" >&2; exit 1; }

# Removes the throwaway profile once the sign-in window closes.
{ setsid --wait "$@"; rm -rf "$profile"; } >/dev/null 2>&1 &
