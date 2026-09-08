#!/usr/bin/env bash
# RPM Fusion setup: release RPMs, freeworld codecs, ffmpeg swap.
# See docs/rpmfusion.md for the why (master-mirror pinning, from-repo list,
# transaction order).
set -oue pipefail

V="$(rpm -E %fedora)"
BASE=https://download1.rpmfusion.org

# Release RPMs pinned to the master mirror (NOT mirrors.rpmfusion.org):
# the redirector has served garbage from out-of-sync mirrors and broken builds.
dnf5 install -y \
    "$BASE/free/fedora/rpmfusion-free-release-$V.noarch.rpm" \
    "$BASE/nonfree/fedora/rpmfusion-nonfree-release-$V.noarch.rpm"

# Swap Fedora's codec-stripped ffmpeg for the real one FIRST: erasing the
# *-free family up front avoids Conflicts when rpmfusion's ffmpeg is ahead of
# Fedora's ffmpeg-free (seen on rawhide during the 8.1 -> 9.0 bump).
# --from-repo limits where ffmpeg may come from: ffmpeg lives in
# rpmfusion-free-updates on released Fedora but in the frozen rpmfusion-free
# base repo on branched/rawhide (their -updates repos are empty until GA), so
# both are listed. A rpmfusion-free* glob is avoided on purpose: it would also
# match the -updates-testing repos.
dnf5 swap -y --allowerasing \
    --from-repo rpmfusion-free,rpmfusion-free-updates \
    ffmpeg-free ffmpeg

# mesa VA/VDPAU freeworld with full codec support (h264, h265, ...) + codecs.
dnf5 install -y \
    mesa-va-drivers-freeworld \
    libavcodec-freeworld \
    gstreamer1-plugin-libav
