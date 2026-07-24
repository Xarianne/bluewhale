#!/bin/bash

set -ouex pipefail

dnf5 install -y \
    fish \
    fuse-libs \
    goverlay \
    input-remapper \
    steam
