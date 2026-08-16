#!/bin/bash

set -ouex pipefail

echo "::group:: Install OpenCode Desktop"

OPENCODE_RPM=/tmp/opencode-desktop.rpm
curl --fail --location --retry 3 --retry-all-errors --show-error \
	--output "${OPENCODE_RPM}" \
	https://github.com/anomalyco/opencode/releases/latest/download/opencode-desktop-linux-x86_64.rpm
dnf5 install -y "${OPENCODE_RPM}"
rm -f "${OPENCODE_RPM}"

echo "OpenCode Desktop installed"
echo "::endgroup::"
