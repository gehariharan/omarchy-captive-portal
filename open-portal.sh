#!/bin/bash
# Opens a captive portal sign-in page

url="${1:?usage: open-portal.sh <url>}"

profile="${XDG_RUNTIME_DIR:-/tmp}/omarchy-captive-portal"
rm -rf "$profile" 2>/dev/null
mkdir -p "$profile"

app_args=(
  --app="$url"
  --user-data-dir="$profile"
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

if [[ -z ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] || ! command -v hyprctl >/dev/null; then
  setsid "$@" >/dev/null 2>&1 &
  exit 0
fi

hyprctl dispatch \
  "hl.dsp.exec_cmd([==[$*]==], { float = true, center = true, size = [==[875 600]==] })" \
  >/dev/null 2>&1 || setsid "$@" >/dev/null 2>&1 &
