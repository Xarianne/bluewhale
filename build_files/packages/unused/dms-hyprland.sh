#!/bin/bash

set -ouex pipefail

dnf5 -y copr enable lionheartp/Hyprland
dnf5 install -y \
    hyprland
dnf5 -y copr disable lionheartp/Hyprland

dnf5 -y copr enable avengemedia/dms
dnf5 install -y \
    dms
dnf5 -y copr disable avengemedia/dms

dnf5 install -y \
    golang-bin
