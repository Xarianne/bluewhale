# /etc/fish/config.fish — system-wide fish config shipped in the image.
# User config (~/.config/fish/config.fish) is sourced after this one.

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

set -gx EDITOR fresh

fish_add_path ~/.local/bin

status is-login; and begin
    # Login shell initialisation
end

# Tool integrations (must run after PATH is set up)
if command -q fzf
    fzf --fish | source
end

if command -q zoxide
    abbr --add -- cd z
    zoxide init fish | source
end

# Starship prompt
if command -q starship
    starship init fish | source
end
