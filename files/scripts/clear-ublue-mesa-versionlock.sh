#!/usr/bin/env bash
set -euo pipefail

# Drop ublue silverblue-main Mesa versionlocks so Terra can distro-sync Mesa.
# ublue locks these after a negativo17 fedora-multimedia mesa-* sync.
# Do not delete intel-media-driver / libva / libheif locks.

dnf5 versionlock delete \
  mesa-dri-drivers \
  mesa-filesystem \
  mesa-libEGL \
  mesa-libGL \
  mesa-libgbm \
  mesa-va-drivers \
  mesa-vulkan-drivers
