#!/usr/bin/bash
set -eoux pipefail

# 1. Enable Terra repos (Refresh metadata to ensure we see the latest 43/Rawhide builds)
dnf5 install -y --refresh --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra$(rpm -E %fedora)" \
  terra-release \
  terra-release-mesa \
  terra-release-multimedia

echo "Upgrading Mesa stack..."
dnf5 upgrade -y --allowerasing \
  mesa* \
  libgbm

echo "Installing Multimedia Codecs..."
# Removed gstreamer1-vaapi because it's now part of gstreamer1-plugins-bad in Terra
dnf5 install -y --allowerasing \
  ffmpeg \
  gstreamer1-plugins-bad \
  gstreamer1-plugins-bad-free-extras \
  gstreamer1-plugins-ugly
