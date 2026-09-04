# Universal Blue packages (`recipes/packages/ublue.yml`)

We build on plain Fedora Atomic, but pull Universal Blue's ujust setup and
udev rules from their official `ublue-os/packages` COPR — the same packages
Universal Blue installs in their own base images (`ublue-os/main`'s
`build_files/install.sh`). Every rebuild tracks upstream automatically.

## What each package provides

- `ublue-os-just`: `ujust` and all default recipes (`00-default`,
  `10-update`, `15-luks`, `20-clean`, `30-distrobox`, `40-nvidia`,
  `50-akmods`), plus the master justfile, which also imports
  `60-custom.just` — where the BlueBuild `justfiles` module places
  `files/justfiles/`. (`ublue-os-luks` is pulled in automatically as a hard
  dependency; it provides the LUKS TPM unlock scripts.)
- `ublue-os-udev-rules`: vendors `fabiscafe/game-devices-udev` (from Codeberg,
  release-tracked), plus Sunshine and Framework device rules.
- `ublue-os-update-services`: flatpak auto-update timers (system + user),
  enabled in `recipes/recipe.yml`'s `systemd` module. Its `/usr/lib` drop-in
  for `rpm-ostreed-automatic.timer` is masked by our own same-named drop-in
  in `files/system/etc/` — `/etc` wins, so our custom schedule stays in
  effect. (It only auto-updates Flatpaks; OS auto-updates remain on our
  `rpm-ostreed-automatic.timer` setup.)
- `uupd`: Universal Blue's unified updater (used by `ujust update` /
  `toggle-updates`, both hidden — see below). Its timer is intentionally
  **not** enabled; use `ujust toggle-updates` to switch at runtime.

## Hiding unwanted recipes (`files/scripts/hide-ujust-recipes.sh`)

Upstream ships recipes we don't want shown (nvidia, broadcom, luks is fine,
update toggle duplicates our own setup, etc.). Instead of vendoring a frozen
copy — which would stop tracking upstream — a build script inserts `just`'s
`[private]` attribute above unwanted recipes in `/usr/share/ublue-os/just/`.
Hidden recipes disappear from `ujust` listings but stay invocable.

The hide list lives in the script as `"file|regex"` entries. If upstream
renames a recipe, the pattern no-ops with a warning and the recipe silently
reappears in listings — re-check the list after upstream updates. Recipe
sources:
https://github.com/ublue-os/packages/tree/main/packages/ublue-os-just/src/recipes

Visible recipes: bios-info, check-idle-power-draw, check-local-overrides,
clean-system, distrobox-assemble, distrobox-new, install-resolve,
logs-last-boot, logs-this-boot, setup-luks-tpm-unlock,
remove-luks-tpm-unlock, update-firmware.

## TPM LUKS auto-unlock: why it needs the initramfs module

The `setup-luks-tpm-unlock` recipe (`→ /usr/libexec/luks-enable-tpm2-autounlock`)
enrolls the TPM via `systemd-cryptenroll`. That works on any base, but the
*unlock at boot* requires the `tpm2-tss` dracut module in the initramfs —
Fedora's stock initramfs may omit it, while Universal Blue's bases regenerate
initramfs at build time (`dracut --no-hostonly --add ostree`), which includes
it. The `type: initramfs` module in `recipes/recipe.yml` does the same
regeneration at build time, making the recipes behave like on an upstream
base.

## Supporting tools from Fedora repos

Recipes call tools not present in the Fedora base, installed in the same
module: `distrobox` (`distrobox-*`), `dmidecode` (`bios-info`), `fpaste`
(`device-info`, hidden), `jq` (`toggle-nvk`, hidden), `mokutil`
(`enroll-secure-boot-key`, hidden). `powerstat` (`check-idle-power-draw`)
arrives via a `Recommends` since weak dependencies are on by default.
