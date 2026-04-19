#!/usr/bin/bash
set -eoux pipefail

# 1. Enable Terra Repos (Mesa & Multimedia are key for your RX 9070)
dnf5 install -y --refresh --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra$(rpm -E %fedora)" \
  terra-release \
  terra-release-multimedia
  # terra-release-mesa \

# 2. Mirroring uBlue Overrides (Adjusted for Terra 44 Names)
# We remove the '-freeworld' suffixes and target the base names
echo "Performing uBlue-style override with Terra packages..."

dnf5 install -y --allowerasing --skip-unavailable \
    ffmpeg \
    gstreamer1-plugins-bad \
    gstreamer1-plugins-ugly \
    gstreamer1-vaapi \
    gstreamer1-plugin-libav
    # mesa-va-drivers \
    # mesa-vulkan-drivers \
    # mesa-dri-drivers \
    # mesa-libgbm \
    # mesa-libEGL \
    # mesa-libGL \

# 3. Cleanup
dnf5 clean all
