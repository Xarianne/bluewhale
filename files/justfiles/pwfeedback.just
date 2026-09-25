# sudo password feedback — show asterisks while typing sudo passwords
#
# Ships /etc/sudoers.d/pwfeedback (via a just recipe rather than a files/ entry,
# because sudoers must be root-owned with 0440 and validated before install —
# a syntactically bad sudoers file can lock you out of sudo entirely).
#
#   just enable-pwfeedback  -> write and validate the drop-in
#   just disable-pwfeedback -> remove it
#
# Note: sudo only shows asterisks for password *prompts*, not for hidden
# verification prompts (e.g. when changing your own password's sudo entry).

SUDOERS_FILE := "/etc/sudoers.d/pwfeedback"

# Enable asterisks while typing sudo passwords
enable-pwfeedback:
    #!/usr/bin/env bash
    set -euo pipefail

    TMP="$(mktemp)"
    trap 'rm -f "$TMP"' EXIT

    printf '# Installed by `just enable-pwfeedback`\nDefaults pwfeedback\n' > "$TMP"

    # visudo -cf validates the file in isolation AND its effect on the real
    # sudoers chain; bail out before touching /etc on any parse error.
    if ! visudo -cf "$TMP"; then
        echo "Validation failed — /etc untouched." >&2
        exit 1
    fi

    install -o root -g root -m 0440 "$TMP" {{SUDOERS_FILE}}
    echo "Password feedback enabled — new sudo sessions will show asterisks."
    echo "(Existing sudo timestamp caches keep the old behaviour until they expire.)"


# Remove the sudoers drop-in again
disable-pwfeedback:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -f {{SUDOERS_FILE}} ]; then
        rm -f {{SUDOERS_FILE}}
        echo "Password feedback disabled — new sudo sessions will be silent."
    else
        echo "{{SUDOERS_FILE}} not present, nothing to do."
    fi