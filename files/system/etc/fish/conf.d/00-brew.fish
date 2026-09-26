if test -x /home/linuxbrew/.linuxbrew/bin/brew
    set -gx HOMEBREW_PREFIX /home/linuxbrew/.linuxbrew
    set -gx HOMEBREW_CELLAR /home/linuxbrew/.linuxbrew/Cellar
    set -gx HOMEBREW_REPOSITORY /home/linuxbrew/.linuxbrew
    fish_add_path --global /home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin
    set -gx MANPATH /home/linuxbrew/.linuxbrew/share/man $MANPATH
    set -gx INFOPATH /home/linuxbrew/.linuxbrew/share/info $INFOPATH
end