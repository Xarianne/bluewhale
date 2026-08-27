#!/usr/bin/env bash
set -euo pipefail

# Work around kf6-kwallet 6.29.0 dual-daemon issue where qtkeychain
# credentials (e.g. Nextcloud's OAuth tokens) don't persist across reboots.
#
# 1. Mask host kwalletd6 D-Bus activation so only ksecretd runs.
# 2. Install the boot-time script that applies a flatpak override
#    removing org.kde.kwalletd6 talk permission from the Nextcloud flatpak.
#
# Upstream issue: https://invent.kde.org/frameworks/kwallet/-/work_items/11

ln -sf /dev/null /usr/share/dbus-1/services/org.kde.kwalletd6.service

mkdir -p /usr/libexec/bluewhale
cp files/scripts/apply-flatpak-overrides.sh /usr/libexec/bluewhale/apply-flatpak-overrides.sh
chmod +x /usr/libexec/bluewhale/apply-flatpak-overrides.sh