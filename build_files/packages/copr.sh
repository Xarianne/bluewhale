#!/bin/bash

set -ouex pipefail

# COPRs are enabled, used to install their packages, then disabled again so
# they don't end up enabled on the final image.

dnf5 -y copr enable bieszczaders/kernel-cachyos-addons
dnf5 install -y \
    scx-scheds \
    scx-tools \
    scx-manager
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons

dnf5 -y copr enable deltacopy/darkly
dnf5 install -y \
    darkly
dnf5 -y copr disable deltacopy/darkly

dnf5 -y copr enable infinality/kwin-effects-better-blur-dx
dnf5 install -y \
    kwin-effects-better-blur-dx
dnf5 -y copr disable infinality/kwin-effects-better-blur-dx

# Hyprland with Dank Material Shell
dnf5 -y copr enable lionheartp/Hyprland
dnf5 install -y \
    hyprland
dnf5 -y copr disable lionheartp/Hyprland

dnf5 -y copr enable avengemedia/dms
dnf5 install -y \
    dms
dnf5 -y copr disable avengemedia/dms
