#!/usr/bin/bash
set -eoux pipefail

# 1. Enable CachyOS Clang-LTO Repo
dnf5 -y copr enable bieszczaders/kernel-cachyos-lto

# 2. Set SELinux Boolean
# Required for CachyOS kernels to load modules properly
setsebool -P domain_kernel_load_modules on

# 3. Install CachyOS LTO Kernel with hooks disabled
# We move the kernel-install hook out of the way so dnf5 doesn't trigger dracut prematurely.
if [ -f /usr/lib/kernel/install.d/05-rpmostree.install ]; then
    mv /usr/lib/kernel/install.d/05-rpmostree.install /usr/lib/kernel/install.d/05-rpmostree.install.bak
fi

dnf5 -y install \
    --allowerasing \
    kernel-cachyos-lto \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules \
    kernel-cachyos-lto-devel-matched

# 4. Restore the hook and manually run depmod
# Now that the files are actually present, we can safely index them.
if [ -f /usr/lib/kernel/install.d/05-rpmostree.install.bak ]; then
    mv /usr/lib/kernel/install.d/05-rpmostree.install.bak /usr/lib/kernel/install.d/05-rpmostree.install
fi

KVER=$(rpm -q --queryformat='%{VERSION}-%{RELEASE}.%{ARCH}' kernel-cachyos-lto-core)
depmod -a "$KVER"

# 5. Cleanup
dnf5 -y copr disable bieszczaders/kernel-cachyos-lto

echo "CachyOS LTO kernel installation complete with manual indexing."
