#!/bin/bash

set -ouex pipefail

dnf5 install -y \
    steam \
    goverlay \
    mangohud \
    vkbasalt \
    input-remapper \
    docker \
    fuse \
    fuse-libs \
    fish \
    runc

# Using Flathub instead; may be a no-op on the Ublue base
dnf5 remove -y fedora-flathub-remote || true
