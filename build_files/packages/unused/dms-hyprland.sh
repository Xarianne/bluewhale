#!/bin/bash

set -ouex pipefail

echo "::group:: Install Hyprland from lionheartp/Hyprland"

copr_install_isolated lionheartp/Hyprland \
    hyprland

echo "::endgroup::"

echo "::group:: Install dms from avengemedia/dms"

copr_install_isolated avengemedia/dms \
    dms

echo "::endgroup::"

echo "::group:: Install additional packages"

dnf5 install -y \
    golang-bin

echo "Additional packages installed"
echo "::endgroup::"

echo "dms-hyprland installation complete"