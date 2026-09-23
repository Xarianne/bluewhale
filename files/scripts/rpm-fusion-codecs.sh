#!/usr/bin/env bash
set -oue pipefail

V="$(rpm -E %fedora)"
BASE=https://download1.rpmfusion.org

# Install RPM Fusion release RPMs from the master mirror (not the redirector).
dnf5 install -y \
    "$BASE/free/fedora/rpmfusion-free-release-$V.noarch.rpm" \
    "$BASE/nonfree/fedora/rpmfusion-nonfree-release-$V.noarch.rpm"

# Swap Fedora's codec-stripped ffmpeg family for the full RPM Fusion build.
# --from-repo covers both released Fedora (-updates) and branched/rawhide
# (-updates is empty until GA). --allowerasing removes the *-free libs.
dnf5 swap -y --allowerasing \
    --from-repo rpmfusion-free,rpmfusion-free-updates \
    ffmpeg-free ffmpeg

# Hardware video acceleration + multimedia codecs.
dnf5 install -y \
    mesa-va-drivers-freeworld \
    mesa-va-drivers-freeworld.i686 \
    libavcodec-freeworld \
    gstreamer1-plugin-libav \
    gstreamer1-plugins-bad-freeworld \
    gstreamer1-plugins-ugly \
    lame
