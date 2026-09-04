#!/usr/bin/bash
# Hides unwanted ujust recipes from `ujust`/`just --list` output by
# inserting the [private] attribute above them in Universal Blue's
# recipe files (/usr/share/ublue-os/just/). Hidden recipes still work
# when invoked directly. See docs/ublue-packages.md.
#
# Each entry below is "file|regex" matched against line start in that
# recipe file. If upstream renames a recipe the pattern silently no-ops
# (a warning is printed) and the recipe reappears in listings — nothing
# breaks, just re-check this list after upstream updates.
set -euxo pipefail

JUSTDIR="/usr/share/ublue-os/just"

HIDE=(
  # 00-default.just
  "00-default.just|^bios:"
  "00-default.just|^enroll-secure-boot-key:"
  "00-default.just|^toggle-user-motd:"
  "00-default.just|^device-info:"
  # 10-update.just (we handle updates ourselves; firmware via update-firmware stays)
  "10-update.just|^update VERB_LEVEL="
  "10-update.just|^alias upgrade :="
  "10-update.just|^changelogs:"
  "10-update.just|^alias changelog :="
  "10-update.just|^toggle-updates ACTION="
  "10-update.just|^alias auto-update :="
  # 30-distrobox.just (assemble/new/install-resolve stay)
  "30-distrobox.just|^setup-distrobox-app CONTAINER="
  # 40-nvidia.just (AMD-only system)
  "40-nvidia.just|^toggle-nvk:"
  # 50-akmods.just
  "50-akmods.just|^configure-broadcom-wl ACTION="
  "50-akmods.just|^alias broadcom-wl :="
)

for entry in "${HIDE[@]}"; do
  file="${JUSTDIR}/${entry%%|*}"
  pattern="${entry#*|}"
  if [[ ! -f "$file" ]]; then
    echo "WARNING: $file does not exist (upstream may have restructured); skipping"
    continue
  fi
  if grep -Eq "$pattern" "$file"; then
    sed -i -E "s|^($pattern)|[private]\n\1|" "$file"
  else
    echo "WARNING: pattern '$pattern' not found in $file (upstream may have renamed it); skipping"
  fi
done
