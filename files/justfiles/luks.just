# LUKS TPM2 auto-unlock — port of Universal Blue's luks-enable-tpm2-autounlock
# for regular (dnf) Fedora. Enrolls a TPM2 key bound to PCRs 7+14 (Secure Boot
# + shim/MOK state) so the root volume unlocks automatically at boot.
#
# Your existing password keyslot is kept as a fallback. BIOS/shim updates or
# Secure Boot changes alter PCRs 7+14 and will require re-enrolling.

# Enable TPM2 auto-unlock for the root LUKS device
enable-tpm2-unlock:
    #!/usr/bin/env bash
    set -euo pipefail

    # Resolve the root LUKS device: kernel cmdline first, /etc/crypttab as fallback.
    CRYPT_DISK=$(sed -n 's/.*rd\.luks\.uuid=\([^ ]*\).*/\1/p' /proc/cmdline | head -n1)
    CRYPT_DISK=${CRYPT_DISK#luks-}
    if [ -z "$CRYPT_DISK" ]; then
        CRYPT_DISK=$(awk '!/^#/ && $2 ~ /^UUID=/ {sub(/^UUID=/, "", $2); print $2; exit}' /etc/crypttab)
    fi
    if [ -z "$CRYPT_DISK" ]; then
        echo "Could not find the root LUKS device in the kernel cmdline or /etc/crypttab." >&2
        exit 1
    fi
    CRYPT_DISK="/dev/disk/by-uuid/$CRYPT_DISK"

    if ! sudo cryptsetup luksDump "$CRYPT_DISK" >/dev/null 2>&1; then
        echo "$CRYPT_DISK is not a LUKS device." >&2
        exit 1
    fi

    # Re-enroll if a TPM2 key already exists.
    if sudo cryptsetup luksDump "$CRYPT_DISK" | grep -q systemd-tpm2; then
        KEYSLOT=$(sudo cryptsetup luksDump "$CRYPT_DISK" | sed -n '/systemd-tpm2$/,/Keyslot:/p' | grep Keyslot | awk '{print $2}')
        echo "TPM2 key already present in LUKS keyslot $KEYSLOT of $CRYPT_DISK."
        read -r -p "Wipe it and re-enroll? (y/N): " -n 1 REPLY
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo systemd-cryptenroll --wipe-slot=tpm2 "$CRYPT_DISK"
        else
            echo "Exiting — nothing changed."
            exit 1
        fi
    fi

    # Enroll the TPM2 key (prompts for your existing LUKS password).
    echo "Enrolling TPM2 unlock — enter your existing LUKS password when prompted."
    sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7+14 "$CRYPT_DISK"

    # Prefer the TPM2 key so the password prompt only appears when TPM unlock fails.
    KEYSLOT=$(sudo cryptsetup luksDump "$CRYPT_DISK" | sed -n '/systemd-tpm2$/,/Keyslot:/p' | grep Keyslot | awk '{print $2}')
    sudo cryptsetup config --key-slot "$KEYSLOT" --priority prefer "$CRYPT_DISK"

    # Make sure the initramfs can do TPM2 unlock. On ostree/bootc systems the
    # initramfs is managed by rpm-ostree — plain `dracut -f` tries to write to
    # /boot/efi/<machine-id>/<kver>, which doesn't exist in the ostree layout.
    if ! grep -q 'tpm2-tss' /etc/dracut.conf.d/*.conf 2>/dev/null; then
        echo 'add_dracutmodules+=" tpm2-tss "' | sudo tee /etc/dracut.conf.d/tpm2-tss.conf >/dev/null
    fi
    if [ -f /run/ostree-booted ]; then
        sudo rpm-ostree initramfs --force-enable
    else
        sudo dracut -f
    fi

    echo "TPM2 LUKS auto-unlock configured. Reboot to test."

# Remove the TPM2 key from the root LUKS device (password unlock remains)
disable-tpm2-unlock:
    #!/usr/bin/env bash
    set -euo pipefail

    CRYPT_DISK=$(sed -n 's/.*rd\.luks\.uuid=\([^ ]*\).*/\1/p' /proc/cmdline | head -n1)
    CRYPT_DISK=${CRYPT_DISK#luks-}
    if [ -z "$CRYPT_DISK" ]; then
        CRYPT_DISK=$(awk '!/^#/ && $2 ~ /^UUID=/ {sub(/^UUID=/, "", $2); print $2; exit}' /etc/crypttab)
    fi
    if [ -z "$CRYPT_DISK" ]; then
        echo "Could not find the root LUKS device in the kernel cmdline or /etc/crypttab." >&2
        exit 1
    fi
    CRYPT_DISK="/dev/disk/by-uuid/$CRYPT_DISK"

    sudo systemd-cryptenroll --wipe-slot=tpm2 "$CRYPT_DISK"
    echo "TPM2 key removed — password unlock only from now on."
