# bluewhale &nbsp; [![bluebuild build badge](https://github.com/xarianne/bluewhale/actions/workflows/build.yml/badge.svg)](https://github.com/xarianne/bluewhale/actions/workflows/build.yml)

A custom Fedora atomic image for someone who likes to tinker and experiment. Not intended for distribution.

## Workarounds

These are temporary fixes applied in the image while waiting for upstream resolution. They will be removed once the upstream projects ship a proper fix.

### KWallet credentials not persisting across reboots

`kf6-kwallet` 6.29.0 ships both `ksecretd` (Secret Service) and `kwalletd6` (legacy KWallet API) in the same package. When both daemons run concurrently, qtkeychain writes credentials via one daemon and reads via the other, so tokens (e.g. Nextcloud's OAuth) don't persist across reboots and the app asks to re-authenticate every boot.

The fix has two parts:
1. **Host:** The legacy `kwalletd6` D-Bus activation file is masked so only `ksecretd` runs on the host. qtkeychain on host apps then falls through to `libsecret`, which talks to `ksecretd` via `org.freedesktop.secrets`.
2. **Flatpak:** A systemd user service applies a flatpak override at boot that removes the `org.kde.kwalletd6` talk permission from the Nextcloud flatpak. This prevents the flatpak sandbox from activating its own `kwalletd6` (bundled in the `org.kde.Platform` runtime), so qtkeychain uses `libsecret` via the host's `ksecretd` (PAM-unlocked) instead.

- **Files:** `recipes/packages/kwallet-fix.yml`, `files/system/usr/lib/systemd/user/bluewhale-flatpak-overrides.service`
- **Upstream issue:** https://invent.kde.org/frameworks/kwallet/-/work_items/11

### Plasma login manager not registering keystrokes

Occasionally, when the Plasma login manager starts, it won't register keystrokes at the password prompt. A 3-second delay is added before the service starts to work around this race condition.

- **File:** `files/system/etc/systemd/system/plasmalogin.service.d/override.conf`
