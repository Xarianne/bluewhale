#!/bin/bash

set -ouex pipefail

# Fuse-libs is a dep for certain App-Images
# Fuse itself already in base image
echo "::group:: Install packages"

dnf5 install -y \
	eza \
	fastfetch \
	fish \
	fuse-libs \
	fzf \
	goverlay \
	input-remapper \
	steam \
	zoxide

echo "Packages installed"
echo "::endgroup::"

echo "Package installation complete"
