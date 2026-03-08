#!/usr/bin/bash
#Use this when using Rawhide/Branched releases
set -eoux pipefail

dnf5 install -y --allowerasing \
  ffmpeg \
  gstreamer1-plugins-bad \
  gstreamer1-plugins-ugly
