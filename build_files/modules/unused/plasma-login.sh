#!/bin/bash

set -ouex pipefail

echo "::group:: Configure Plasma Login Manager greeter"

# Fix: the greeter runs as user 'plasmalogin' with no inherited locale,
# causing Qt to fall back to C/ANSI_X3.4-1968 instead of UTF-8.
# This is a documented aggravating factor in RH #2483625.
# We append to the upstream file rather than overwriting it, so future
# base-image updates to /etc/sysconfig/plasmalogin are preserved.

SYSCONFIG_FILE="/etc/sysconfig/plasmalogin"

if ! grep -q '^LANG=' "${SYSCONFIG_FILE}"; then
	cat >>"${SYSCONFIG_FILE}" <<'EOF'
# Fix: greeter runs as user 'plasmalogin' with no inherited locale,
# causing Qt to fall back to C/ANSI_X3.4-1968. RH #2483625.
LANG=en_GB.UTF-8
LC_ALL=en_GB.UTF-8
EOF
	echo "Added locale settings to ${SYSCONFIG_FILE}"
else
	echo "Locale already set in ${SYSCONFIG_FILE}, skipping"
fi

# Fix the actual race condition from RH #2483625: the greeter's QML singletons
# (Authenticator, UserModel, SessionModel, etc.) query AccountsService over
# D-Bus. If plasmalogin starts before accounts-daemon is ready, those singletons
# fail to initialize, the login screen is black/empty, and the greeter may crash.
# A drop-in in /etc/systemd/system/plasmalogin.service.d orders the service after
# accounts-daemon using Wants (not Requires), so a failing accounts-daemon does
# not prevent the greeter from starting; system_files/ already copies it to /.
echo "Plasma Login Manager systemd drop-in is provided via system_files/"

echo "Plasma Login Manager configured"
echo "::endgroup::"
