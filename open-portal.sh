#!/bin/bash
# Opens a captive portal sign-in page

url="${1:?usage: open-portal.sh <url>}"

if [[ ! ${url,,} =~ ^https?://[^[:cntrl:]]+$ ]] || [[ $url == *']==]'* ]]; then
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

if command -v chromium >/dev/null; then
  set -- chromium "${app_args[@]}"
else
  case "$(omarchy-default-browser 2>/dev/null)" in
    chrome)       set -- google-chrome-stable "${app_args[@]}" ;;
    brave)        set -- brave "${app_args[@]}" ;;
    brave-origin) set -- brave-origin "${app_args[@]}" ;;
    edge)         set -- microsoft-edge-stable "${app_args[@]}" ;;
    firefox)      set -- firefox --private-window "$url" ;;
    zen)          set -- zen-browser --private-window "$url" ;;
    *)            set -- xdg-open "$url" ;;
  esac
fi

command -v "$1" >/dev/null || { echo "no browser available to open $url" >&2; exit 1; }

setsid "$@" >/dev/null 2>&1 &
