# ------------------------------------------------------------------------------
# opencode
# ------------------------------------------------------------------------------

# Clear opencode session history (transcripts, logs, snapshots, prompt
# history). Preserves auth, config, plugins, and model cache.
[group('AI')]
clean-opencode:
    #!/usr/bin/bash
    if ! gum confirm "Clear opencode session history? (transcripts, logs, snapshots)"; then
        exit 0
    fi
    rm -f ~/.local/share/opencode/opencode.db* \
          ~/.local/share/opencode/opencode-stable.db*
    rm -rf ~/.local/share/opencode/log/* \
           ~/.local/share/opencode/plans/* \
           ~/.local/share/opencode/snapshot/* \
           ~/.local/share/opencode/tool-output/* \
           ~/.local/share/opencode/repos/*
    rm -f ~/.local/state/opencode/prompt-history.jsonl
    echo "opencode session history cleared."
