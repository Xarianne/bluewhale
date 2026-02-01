#!/usr/bin/bash
set -eoux pipefail

# 1. Enable CachyOS add-on repo
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# 2. Install addons

dnf5 -y install \
    scx-scheds \
    scx-tools \
    scx-manager 

dnf5 -y swap zram-generator-defaults cachyos-settings

# 3. Cleanup
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons

echo "CachyOS add-ons install complete."
