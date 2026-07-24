#!/bin/bash

set -ouex pipefail

# Fuse-libs is a dep for certain App-Images
# Fuse itself already in base image
dnf5 install -y \
    fish \
    fuse-libs \
    goverlay \
    input-remapper \
    steam
