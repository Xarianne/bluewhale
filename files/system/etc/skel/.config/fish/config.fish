# ~/.config/fish/config.fish

# Only execute this file once per shell.
set -q __fish_config_sourced; and exit
set -g __fish_config_sourced 1

# Distrobox container isolation guard
if set -q CONTAINER_ID
    if test -f ~/.config/distrobox/$CONTAINER_ID/fish/config.fish
        source ~/.config/distrobox/$CONTAINER_ID/fish/config.fish
    end
    return
end

set -gx EDITOR kate
set -gx VISUAL kate
# set -gx JUST_JUSTFILE ~/Just/justfile
# set -gx XCURSOR_PATH ~/.nix-profile/share/icons:/usr/share/icons:/usr/share/pixmaps

fish_add_path ~/.local/bin
fish_add_path ~/.lmstudio/bin
fish_add_path ~/.npm-global/bin
if test -d $HOME/.cargo/bin
    fish_add_path $HOME/.cargo/bin
end

status is-login; and begin
    # Login shell initialisation
end

