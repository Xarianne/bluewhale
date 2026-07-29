#!/bin/bash

set -ouex pipefail

# Fuse-libs is a dep for certain App-Images
# Fuse itself already in base image
echo "::group:: Install packages"

dnf5 install -y \
    fish \
    fuse-libs \
    goverlay \
    input-remapper \
    steam \
    shellcheck # Linter for scripts used by this image

echo "Packages installed"
echo "::endgroup::"

echo "Package installation complete"