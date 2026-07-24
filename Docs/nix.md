# Nix Package Manager

This image is kept as lean as possible; software is installed via the Nix package manager and Flatpaks rather than distro packages.

While Homebrew is commonly used, I prefer Nix because it makes it easier to track what I installed. 

Homebrew was pulling in dependencies and toolchains that ended up shadowing my Fedora installation, whereas Nix keeps each package's dependencies isolated.
