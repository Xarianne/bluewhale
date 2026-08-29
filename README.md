# bluewhale &nbsp; [![bluebuild build badge](https://github.com/xarianne/bluewhale/actions/workflows/build.yml/badge.svg)](https://github.com/xarianne/bluewhale/actions/workflows/build.yml)

A custom Fedora atomic image for someone who likes to tinker and experiment. Not intended for distribution.

## Workarounds

These are temporary fixes applied in the image while waiting for upstream resolution. They will be removed once the upstream projects ship a proper fix.

### Plasma login manager not registering keystrokes

Occasionally, when the Plasma login manager starts, it won't register keystrokes at the password prompt. A 3-second delay is added before the service starts to work around this race condition.

- **File:** `files/system/etc/systemd/system/plasmalogin.service.d/override.conf`

### KWallet not unlocking with Plasma 6's ksecretd

The base `authselect` `local` profile has no `with-pam-kwallet` feature. A custom authselect profile (`custom/bluewhale`) is created at build time, based on `local` with symlinks (so unmodified files inherit Fedora updates), adding `pam_kwallet5.so` lines with `kwalletd=/usr/bin/ksecretd` (Plasma 6's Secret Service daemon) to `system-auth` and `password-auth`.

- **Script:** `files/scripts/pam-kwallet-authselect.sh`
