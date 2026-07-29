#!/bin/bash

set -ouex pipefail

echo "::group:: Install COSMIC desktop"

dnf5 install -y '@cosmic-desktop'

echo "COSMIC desktop installed"
echo "::endgroup::"

echo "::group:: Configure COSMIC services"

# The masking below is needed so that the cosmic-greeter
# doesn't try to take over from Plasma Login Manager
systemctl mask cosmic-greeter.service
systemctl mask cosmic-greeter-daemon.service

echo "COSMIC services configured"
echo "::endgroup::"

echo "COSMIC desktop installation complete"
