#!/bin/bash

set -ouex pipefail

# COPRs are enabled, used to install their packages, then disabled again so
# they don't end up enabled on the final image.

echo "::group:: Install scx schedulers from bieszczaders/kernel-cachyos-addons"

copr_install_isolated bieszczaders/kernel-cachyos-addons \
	scx-scheds \
	scx-tools \
	scx-manager

echo "::endgroup::"

echo "::group:: Install darkly theme from deltacopy/darkly"

copr_install_isolated deltacopy/darkly \
	darkly

echo "::endgroup::"

echo "::group:: Install kwin-effects-better-blur-dx from infinality"

copr_install_isolated infinality/kwin-effects-better-blur-dx \
	kwin-effects-better-blur-dx

echo "::endgroup::"

echo "COPR package installation complete"
