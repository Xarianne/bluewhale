# Universal Blue packages (`recipes/packages/ublue.yml`)

We build on plain Fedora Atomic, but pull Universal Blue's ujust setup and
udev rules from their official `ublue-os/packages` COPR — the same packages
Universal Blue installs in their own base images (`ublue-os/main`'s
`build_files/install.sh`). Every rebuild tracks upstream automatically.

## What each package provides

- `ublue-os-just`: `ujust` and **all** default recipes (`00-default`,
  `10-update`, `15-luks`, `20-clean`, `30-distrobox`, `40-nvidia`,
  `50-akmods`), plus the master justfile, which also imports
  `60-custom.just` — where the BlueBuild `justfiles` module places
  `files/justfiles/`. (`ublue-os-luks` is pulled in automatically as a hard
  dependency.)
- `ublue-os-udev-rules`: vendors `fabiscafe/game-devices-udev` (from Codeberg,
  release-tracked), plus Sunshine and Framework device rules — the same udev
  rules Universal Blue ships in their base images.
- `ublue-os-update-services`: flatpak auto-update timers (system + user) that
  `ujust toggle-updates` switches alongside `rpm-ostreed-automatic`. Its
  `/usr/lib` drop-in for `rpm-ostreed-automatic.timer` is masked by our own
  same-named drop-in in `files/system/etc/` — `/etc` wins, so our custom
  schedule stays in effect. Both flatpak timers are enabled explicitly in
  `recipes/recipe.yml`'s `systemd` module (RPM presets don't reliably apply
  in OCI image builds).
- `uupd`: Universal Blue's unified updater, used by `ujust update` and
  `ujust toggle-updates`. Its timer is intentionally **not** enabled;
  automatic system updates stay on our `rpm-ostreed-automatic` setup.
  Use `ujust toggle-updates` to switch at runtime.

## Supporting tools from Fedora repos

Recipes call tools not present in the Fedora base, installed in the same
module: `distrobox` (`distrobox-*`), `dmidecode` (`bios-info`), `fpaste`
(`device-info`), `jq` (`toggle-nvk`), `mokutil` (`enroll-secure-boot-key`).
`powerstat` (`check-idle-power-draw`) arrives via a `Recommends` since
weak dependencies are on by default.
