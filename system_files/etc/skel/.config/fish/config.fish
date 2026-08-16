# Only execute this file once per shell.
set -q __fish_config_sourced; and exit
set -g __fish_config_sourced 1

# Distrobox container isolation guard.
if set -q CONTAINER_ID
    if test -f ~/.config/distrobox/$CONTAINER_ID/fish/config.fish
        source ~/.config/distrobox/$CONTAINER_ID/fish/config.fish
    end
    return
end

set -gx EDITOR kate
set -gx VISUAL kate
set -gx XCURSOR_PATH ~/.nix-profile/share/icons:/usr/share/icons:/usr/share/pixmaps

fish_add_path ~/.local/bin
fish_add_path ~/.lmstudio/bin
fish_add_path ~/.opencode/bin
if test -d $HOME/.cargo/bin
    fish_add_path $HOME/.cargo/bin
end

# Homebrew — keep system tools ahead of Homebrew tools.
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    set -gx HOMEBREW_PREFIX /home/linuxbrew/.linuxbrew
    set -gx HOMEBREW_CELLAR $HOMEBREW_PREFIX/Cellar
    set -gx HOMEBREW_REPOSITORY $HOMEBREW_PREFIX
    fish_add_path -aP $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin
    set -gx MANPATH $HOMEBREW_PREFIX/share/man $MANPATH
    set -gx INFOPATH $HOMEBREW_PREFIX/share/info $INFOPATH
end

# Proton Pass SSH agent and keyring integration.
set -gx SSH_AUTH_SOCK $HOME/.ssh/proton-pass-agent.sock
set -gx PROTON_PASS_KEY_PROVIDER keyring
set -gx PROTON_PASS_LINUX_KEYRING kernel

status is-login; and begin
    # Login shell initialisation
end
