# Noctalia family notes

Notes on the Noctalia family (<https://noctalia.dev/>): the Noctalia shell,
the Umbriel compositor, and the Noctalia Greeter login screen.

## Where the packages come from

- `noctalia` (shell, v5) and `greetd` come from the Fedora repos.
- `umbriel-nightly` and `noctalia-greeter` come from the **Terra** repo
  ([terra.fyralabs.com](https://terra.fyralabs.com/)), vendored as
  `files/dnf/terra.repo`; Umbriel is not packaged in Fedora. Umbriel is only
  available on Terra as nightly git snapshots (`umbriel-nightly`), with
  `xwayland-satellite` and `xdg-desktop-portal-umbriel-nightly` pulled in as
  dependencies. There is no stable Fedora/Umbriel package yet.
- The Terra GPG key URL in `recipes/packages/noctalia.yml` hardcodes
  `terra44`; bump it together with `image-version` in the main recipe.

## The login screen (Greeter instead of GDM)

- The recipe disables `gdm.service` and enables `greetd.service`; both alias
  `display-manager.service`, so GDM must be disabled for greetd to win.
  GDM stays installed (it's part of the GNOME base), just not running.
- `files/system/etc/greetd/config.toml` points greetd at
  `/usr/bin/noctalia-greeter-session` (owned by the greetd package as
  `%config(noreplace)`, so the packaged default lands as `.rpmnew`, ours wins).
- `user = "greetd"` **must** stay as-is: Fedora's greetd sysusers entry
  creates a `greetd` user, not the upstream example's `greeter`.
- `files/system/usr/lib/tmpfiles.d/noctalia-greeter.conf` creates
  `/var/lib/noctalia-greeter` at boot (owned by `greetd`). Needed because the
  Terra package strips the upstream tmpfiles config, and `/var` content from
  the image is not carried into deployments.

## GNOME under the greeter

GNOME is kept and can be selected in the greeter's session picker, but
upstream notes GNOME support via greetd is **best-effort**
(the greeter sets `XDG_SESSION_TYPE`/`XDG_CURRENT_DESKTOP`, but GNOME expects
a systemd-managed user session; if it logs straight back to the greeter, the
fallback is re-enabling GDM). See
<https://docs.noctalia.dev/greeter/#default-session>.

## Shell ↔ greeter sync

With both installed, **Settings → Security → Noctalia Greeter → Sync Now**
copies wallpaper/palette/font to the login screen. It needs polkit
(`pkexec`) approval; enable **Settings → Security → Polkit agent** in
Noctalia to approve from the desktop.

Source docs: <https://docs.noctalia.dev/> (Noctalia / Umbriel / Greeter).
