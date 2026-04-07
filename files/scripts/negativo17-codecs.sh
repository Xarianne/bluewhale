#!/usr/bin/bash
set -eoux pipefail

dnf5 install -y --allowerasing \
  ffmpeg \
  gstreamer1-plugins-bad \
  gstreamer1-plugins-ugly
