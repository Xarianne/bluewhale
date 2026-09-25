# Fedora system maintenance — prune podman images, autoremove packages, check rpmnew/rpmsave configs

# Remove all unused podman images, including untagged (dangling) ones.
# Images referenced by any container (running or stopped) are kept.
prune-images:
    podman image prune -a -f

# Show all messages from this boot
logs-this-boot:
    sudo journalctl --no-hostname -b 0

# Show all messages from last boot
logs-last-boot:
    sudo journalctl --no-hostname -b -1

# Save all messages from this boot to ~/this-boot.log
save-this-boot:
    sudo journalctl --no-hostname -b 0 > ~/this-boot.log
    echo "Saved to ~/this-boot.log"

# Save all messages from last boot to ~/last-boot.log
save-last-boot:
    sudo journalctl --no-hostname -b -1 > ~/last-boot.log
    echo "Saved to ~/last-boot.log"
