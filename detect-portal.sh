#!/bin/bash
# Probes a captive portal endpoint and prints the sign-in URL.

PROBE="${1:-http://captive.apple.com/hotspot-detect.html}"

portal=""
status=1

response=$(curl -sS -m 5 -i \
  -A "CaptiveNetworkSupport-355.200.27 wispr" \
  "$PROBE" 2>/dev/null | head -c 65536)

if [[ -n $response ]]; then
  location=$(printf '%s' "$response" \
    | grep -i '^location:' \
    | head -1 \
    | sed 's/^[Ll]ocation:[[:space:]]*//; s/\r$//')

  if [[ -n $location ]]; then
    portal=$location
  elif ! grep -qi '<TITLE>Success</TITLE>' <<<"$response"; then
    portal=$PROBE
  fi
fi

if [[ -n $portal ]]; then
  echo "$portal"
  status=0
fi

exit $status
