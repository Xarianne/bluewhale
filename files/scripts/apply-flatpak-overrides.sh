#!/usr/bin/env bash
set -euo pipefail

# Applies flatpak overrides that cannot be baked into the ostree image
# because /var/lib/flatpak is not committed to the ostree layer.
#
# This removes the org.kde.kwalletd6 talk permission from the Nextcloud
# flatpak so its sandboxed qtkeychain uses libsecret (host ksecretd)
# instead of activating the runtime's own kwalletd6.
#
# Upstream issue: https://invent.kde.org/frameworks/kwallet/-/work_items/11

OVERRIDE_DIR="/var/lib/flatpak/overrides"
OVERRIDE_FILE="${OVERRIDE_DIR}/com.nextcloud.desktopclient.nextcloud"

mkdir -p "${OVERRIDE_DIR}"
cat > "${OVERRIDE_FILE}" << 'EOF'
[Context]
[Session Bus Policy]
org.kde.kwalletd6=none
EOF