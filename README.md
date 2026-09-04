# Captive Portal

Detects captive portals on Wi-Fi networks and opens the sign-in page in a
centered floating window.

Many public networks connect successfully but block traffic until you sign in
on a portal page. This plugin detects that state, sends a notification naming
the network, and opens the sign-in page.

## Installation

```bash
omarchy plugin add https://github.com/zachfleeman/omarchy-captive-portal
omarchy plugin enable io.github.zachfleeman.captive
```

## Usage

Detection and opening are automatic.

```bash
omarchy-shell captive open     # reopen the sign-in page
omarchy-shell captive check    # force a probe now
omarchy-shell captive status   # connectivity, SSID, pending portal
```

## How it works

NetworkManager signals when a network connects but is not carrying traffic,
triggering a probe against `captive.apple.com` to check whether the connection
is being intercepted. If it is, the probe returns the portal's sign-in URL and
the plugin opens it.

If a portal does not load, DNS is worth checking. Portals redirect by
intercepting DNS, so a pinned public resolver can stop that from working.
`omarchy dns DHCP` restores DNS from the network being joined.

## What it does on your system

- Requests `http://captive.apple.com/hotspot-detect.html` when connectivity is
  not full, to detect interception and read the sign-in URL
- Launches a centered sign-in browser window in a throwaway profile under
  `$XDG_RUNTIME_DIR`, removed when the window closes. Browsers it does not
  recognize are opened with `xdg-open`, which uses your normal session
- Sends desktop notifications through `notify-send`

It requires no elevated privileges, installs no services, and writes nothing
outside that runtime profile directory.

## Uninstalling

```bash
omarchy plugin remove io.github.zachfleeman.captive
```

## License

MIT.
