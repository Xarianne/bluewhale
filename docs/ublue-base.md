# Universal Blue base

When using the Universal Blue base, the below applies.

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
clean-system,
logs-last-boot, logs-this-boot, setup-luks-tpm-unlock,
remove-luks-tpm-unlock, update-firmware.

## TPM LUKS auto-unlock: why it needs the initramfs module (only if not using Universal Blue base)

The `setup-luks-tpm-unlock` recipe (`→ /usr/libexec/luks-enable-tpm2-autounlock`)
enrolls the TPM via `systemd-cryptenroll`. That works on any base, but the
*unlock at boot* requires the `tpm2-tss` dracut module in the initramfs —
Fedora's stock initramfs may omit it, while Universal Blue's bases regenerate
initramfs at build time (`dracut --no-hostonly --add ostree`), which includes
it. The `type: initramfs` module in `recipes/recipe.yml` does the same
regeneration at build time, making the recipes behave like on an upstream
base.
