# Hyprland with Dank Material Shell

The Dank Material Shell install script won't work on an immutable Fedora installation. 

The dependencies have been installed in this bootc image, and they consist of:

1. The hyprland COPR DMS uses, which is lionheartp/Hyprland; it is **not** the commonly used solopasha/hyprland

2. The official DMS COPR following the **stable** release: avengemedia/dms

3. The Go binary which already exists in the official Fedora repos

After a successful rebuild, the DMS install shell will work, and will build the go binaries needed and set up the dotfiles. Link to the install script: https://danklinux.com/docs/getting-started

If the dependencies change and suddenly DMS stops working, check the DMS docs. A simple test is also to make a Fedora Distrobox with its own home folder, and run the script there. You will be able to see exactly which software the script installed, and the resulting dotfiles. 

The Distrobox is also a good way to isolate the changes to the home folder for version control should it be needed, as the dotfiles will be installed in one contained folder (the one used to make the box's own home folder).
