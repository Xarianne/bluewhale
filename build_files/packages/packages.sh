#!/bin/bash

set -ouex pipefail

dnf5 install -y \
    fish \
    fuse \
    goverlay \
    input-remapper \
    steam
