#!/bin/bash

set -ouex pipefail

# Keep Fedora identity fields for compatibility while branding the installed OS.
FEDORA_VERSION="$(sed -n 's/^VERSION_ID=//p' /usr/lib/os-release | tr -d '"')"
sed -i \
    -e 's/^NAME=.*/NAME="Bluewhale"/' \
    -e "s/^PRETTY_NAME=.*/PRETTY_NAME=\"Bluewhale (Fedora Linux ${FEDORA_VERSION})\"/" \
    /usr/lib/os-release
