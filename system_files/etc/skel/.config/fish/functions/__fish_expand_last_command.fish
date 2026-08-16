function __fish_expand_last_command --description 'Expand !! to the previous command (bash-style history expansion)'
    set -l last (history --max 1)
    if test -z "$last"
        printf '%s' !!
        return
    end
    printf '%s' $last
end
