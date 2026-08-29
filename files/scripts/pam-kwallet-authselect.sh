#!/bin/sh
set -eu

# Create a custom authselect profile based on 'local' with symlinks
# so unmodified files inherit future Fedora base profile updates.
# Only system-auth and password-auth are copied and modified to add
# pam_kwallet5.so lines with a 'with-pam-kwallet' feature conditional,
# mirroring the existing with-pam-gnome-keyring pattern.
#
# Plasma 6 requires kwalletd=/usr/bin/ksecretd on the session line
# (Arch Wiki: KDE Wallet - Configure PAM on Plasma 6).

BASE_DIR=/usr/share/authselect/default/local
PROFILE_DIR=/etc/authselect/custom/bluewhale

# Remove existing profile if this script re-runs
rm -rf "$PROFILE_DIR"

# Create profile with all files symlinked to the base local profile
authselect create-profile bluewhale -b local --symlink-meta --symlink-pam

# Break symlink for system-auth, copy current content, add kwallet lines
cp --remove-destination "$BASE_DIR/system-auth" "$PROFILE_DIR/system-auth"

# Add kwallet auth line after the gnome-keyring auth line
sed -i '/pam_gnome_keyring.so.*with-pam-gnome-keyring/a auth        optional                                     pam_kwallet5.so                                       {include if "with-pam-kwallet"}' "$PROFILE_DIR/system-auth"

# Add kwallet session line after the gnome-keyring session line, with ksecretd
sed -i '/pam_gnome_keyring.so.*with-pam-gnome-keyring/a session     optional                                     pam_kwallet5.so auto_start kwalletd=/usr/bin/ksecretd  {include if "with-pam-kwallet"}' "$PROFILE_DIR/system-auth"

# Break symlink for password-auth, copy current content, add kwallet lines
cp --remove-destination "$BASE_DIR/password-auth" "$PROFILE_DIR/password-auth"

# Add kwallet auth line after the gnome-keyring auth line
sed -i '/pam_gnome_keyring.so.*with-pam-gnome-keyring/a auth        optional                                     pam_kwallet5.so                                       {include if "with-pam-kwallet"}' "$PROFILE_DIR/password-auth"

# Add kwallet session line after the gnome-keyring session line, with ksecretd
sed -i '/pam_gnome_keyring.so.*with-pam-gnome-keyring/a session     optional                                     pam_kwallet5.so auto_start kwalletd=/usr/bin/ksecretd  {include if "with-pam-kwallet"}' "$PROFILE_DIR/password-auth"

# Select the custom profile with current features + with-pam-kwallet
authselect select custom/bluewhale with-silent-lastlog with-mdns4 with-fingerprint with-pam-kwallet