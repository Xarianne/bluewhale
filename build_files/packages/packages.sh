#!/bin/bash

set -ouex pipefail

dnf5 install -y \
    fish \
    fuse \
    fuse-libs \
    goverlay \
    input-remapper \
    steam
