# -------------------------------------------------------------------------------
# Home Manager (Nix flake setup)
# -------------------------------------------------------------------------------

# Install Determinate Nix if missing and set up a flake-based Home Manager
# configuration in ~/.config/home-manager.
[group('nix')]
setup-home-manager:
    #!/usr/bin/bash
    set -euo pipefail

    if command -v nix >/dev/null 2>&1; then
        echo "Nix is already installed: $(nix --version)"
    else
        echo "Installing Determinate Nix..."
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
            sh -s -- install --no-confirm
    fi

    HM_DIR="$HOME/.config/home-manager"
    if [ -d "$HM_DIR" ]; then
        echo "Home Manager directory already exists at $HM_DIR"
    else
        echo "Creating Home Manager flake directory at $HM_DIR..."
        mkdir -p "$HM_DIR"
    fi

    if [ ! -f "$HM_DIR/flake.nix" ]; then
        printf '%s\n' \
            '{' \
            '  description = "Home Manager configuration";' \
            '' \
            '  inputs = {' \
            '    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";' \
            '    home-manager = {' \
            '      url = "github:nix-community/home-manager";' \
            '      inputs.nixpkgs.follows = "nixpkgs";' \
            '    };' \
            '  };' \
            '' \
            '  outputs = { self, nixpkgs, home-manager, ... }:' \
            '    let' \
            '      system = "x86_64-linux";' \
            '      pkgs = import nixpkgs { inherit system; };' \
            '    in {' \
            '      homeConfigurations."xariann" = home-manager.lib.homeManagerConfiguration {' \
            '        inherit pkgs;' \
            '        modules = [ ./home.nix ];' \
            '      };' \
            '    };' \
            '}' > "$HM_DIR/flake.nix"
        echo "Created $HM_DIR/flake.nix"
    fi

    if [ ! -f "$HM_DIR/home.nix" ]; then
        printf '%s\n' \
            '{ config, pkgs, ... }:' \
            '' \
            '{' \
            '  home.username = "xariann";' \
            '  home.homeDirectory = "/var/home/xariann";' \
            '  home.stateVersion = "25.05";' \
            '' \
            '  # Example package (commented out). Add your own here.' \
            '  # home.packages = with pkgs; [ home-manager ];' \
            '' \
            '  programs.home-manager.enable = true;' \
            '}' > "$HM_DIR/home.nix"
        echo "Created $HM_DIR/home.nix"
    fi

    echo "Activating Home Manager..."
    nix run home-manager/master -- switch --flake "$HM_DIR"

    echo "Home Manager setup complete."

# Switch to the current Home Manager flake configuration.
[group('nix')]
switch-home-manager:
    #!/usr/bin/bash
    set -euo pipefail
    HM_DIR="$HOME/.config/home-manager"
    if [ ! -f "$HM_DIR/flake.nix" ]; then
        echo "No Home Manager flake found at $HM_DIR. Run 'just setup-home-manager' first."
        exit 1
    fi
    nix run home-manager/master -- switch --flake "$HM_DIR"

# Update Home Manager and nixpkgs inputs, then switch.
[group('nix')]
update-home-manager:
    #!/usr/bin/bash
    set -euo pipefail
    HM_DIR="$HOME/.config/home-manager"
    if [ ! -f "$HM_DIR/flake.nix" ]; then
        echo "No Home Manager flake found at $HM_DIR. Run 'just setup-home-manager' first."
        exit 1
    fi
    nix flake update "$HM_DIR"
    nix run home-manager/master -- switch --flake "$HM_DIR"
