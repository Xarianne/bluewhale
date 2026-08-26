#!/bin/sh
# Copy image-shipped fish defaults from /usr/etc/skel/.config/fish/ into the
# default user's (UID 1000) home directory on every boot.
#
# Image files overwrite their existing counterparts so config updates ship via
# image rebases; files the user added that aren't in the image are left alone.
#
# Mirrors the two-phase pattern used by the BlueBuild brew module: build-time
# staging in a system directory + run-time copy as the default user.

set -eu

SKEL_DIR="/usr/etc/skel/.config/fish"

# Nothing to do if the image didn't ship fish defaults.
[ -d "$SKEL_DIR" ] || exit 0

# Resolve the default user's home without depending on getent pwent output
# formatting (busybox/coreutils differ). id -u is universally available.
UID_DEFAULT=1000
if ! id -u "$UID_DEFAULT" >/dev/null 2>&1; then
    exit 0
fi

HOME_DIR=$(getent passwd "$UID_DEFAULT" | cut -d: -f6)
[ -n "$HOME_DIR" ] || exit 0

DEST_DIR="$HOME_DIR/.config/fish"

# Ensure destination tree exists.
mkdir -p "$DEST_DIR/conf.d" "$DEST_DIR/functions"

# Copy each top-level entry from the staged tree, overwriting image files but
# preserving any extra files the user added (no --delete equivalent).
# cp -a preserves mode, ownership context, and timestamps; we re-chown after.
for entry in "$SKEL_DIR"/*; do
    [ -e "$entry" ] || continue
    cp -a "$entry" "$DEST_DIR/"
done

# Everything under the user's home must be owned by them.
chown -R "$UID_DEFAULT:$UID_DEFAULT" "$DEST_DIR"

exit 0