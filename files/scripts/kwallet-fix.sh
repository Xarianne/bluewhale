#!/usr/bin/env bash
set -euo pipefail

# Work around kf6-kwallet 6.29.0 dual-daemon issue where qtkeychain
# credentials (e.g. Nextcloud's OAuth tokens) don't persist across reboots.
#
# 1. Mask host kwalletd6 D-Bus activation so only ksecretd runs.
# 2. Install the boot-time script that applies a flatpak override
#    removing org.kde.kwalletd6 talk permission from the Nextcloud flatpak,
#    so its sandboxed qtkeychain uses libsecret (host ksecretd) instead
#    of activating the runtime's own kwalletd6.
#
# Upstream issue: https://invent.kde.org/frameworks/kwallet/-/work_items/11

ln -sf /dev/null /usr/share/dbus-1/services/org.kde.kwalletd6.service

mkdir -p /usr/libexec/bluewhale
cat > /usr/libexec/bluewhale/apply-flatpak-overrides.sh << 'BOOTSCRIPT'
#!/usr/bin/env bash
set -euo pipefail

OVERRIDE_DIR="/var/lib/flatpak/overrides"
OVERRIDE_FILE="${OVERRIDE_DIR}/com.nextcloud.desktopclient.nextcloud"

mkdir -p "${OVERRIDE_DIR}"
cat > "${OVERRIDE_FILE}" << 'EOF'
[Context]
[Session Bus Policy]
org.kde.kwalletd6=none
EOF
BOOTSCRIPT
chmod +x /usr/libexec/bluewhale/apply-flatpak-overrides.sh