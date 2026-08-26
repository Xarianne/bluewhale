#!/bin/sh
# Install Homebrew CLI tools declared in the image-shipped Brewfile into the
# default user's (UID 1000) home, once per new image deployment.
#
# Mirrors the two-phase pattern used by the BlueBuild brew module and
# fish-defaults.service: build-time staging in /usr/etc/skel + run-time
# application as the default user, guarded by a state-file marker so the
# bundle install only runs once per ostree deployment (a rebase gives a
# fresh /etc, which resets the marker and re-triggers the install).

set -eu

SKEL_FILE="/usr/etc/skel/Brewfile"
MARKER="/etc/.brew-bundle"
UID_DEFAULT=1000

# Nothing to do if the image didn't ship a Brewfile.
[ -f "$SKEL_FILE" ] || exit 0

# Already installed for this deployment; nothing to do.
[ -f "$MARKER" ] && exit 0

# Resolve the default user.
if ! id -u "$UID_DEFAULT" >/dev/null 2>&1; then
    exit 0
fi
USER_NAME=$(id -nu "$UID_DEFAULT")
HOME_DIR=$(getent passwd "$UID_DEFAULT" | cut -d: -f6)
[ -n "$HOME_DIR" ] || exit 0

# Brew must be installed (brew-setup.service should have run before us).
BREW="/home/linuxbrew/.linuxbrew/bin/brew"
[ -x "$BREW" ] || exit 0

# Stage the Brewfile into the user's home under ~/brewfile/.
DEST_DIR="$HOME_DIR/brewfile"
mkdir -p "$DEST_DIR"
cp "$SKEL_FILE" "$DEST_DIR/Brewfile"
chown -R "$UID_DEFAULT:$UID_DEFAULT" "$DEST_DIR"

# Run `brew bundle install` as the default user. Non-destructive: it only
# adds missing formulae/taps and leaves anything else untouched.
HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
BREW_PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin"

runuser -u "$USER_NAME" -- env \
    HOME="$HOME_DIR" \
    HOMEBREW_PREFIX="$HOMEBREW_PREFIX" \
    HOMEBREW_CELLAR="$HOMEBREW_CELLAR" \
    HOMEBREW_REPOSITORY="$HOMEBREW_REPOSITORY" \
    PATH="$BREW_PATH:$PATH" \
    "$BREW" bundle install --file="$DEST_DIR/Brewfile"

# Mark this deployment as done.
touch "$MARKER"

exit 0