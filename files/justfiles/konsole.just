# Konsole — fish profile, Catppuccin Macchiato scheme and the Google Sans Code
# Nerd Font Mono. Flat recipes via the gate, e.g. `just setup-konsole`
#
#   just setup-konsole   -> the whole thing: font + scheme + profile
#   just verify-konsole  -> check font, scheme and fastfetch glyph coverage
#
# The steps setup-konsole runs are private (leading underscore, like firewall.just);
# they stay directly runnable, e.g. `just _install-google-font`.
#
# Both downloads track upstream rather than a pinned revision:
#   - font  -> nerd-fonts' latest release (the tag is recorded in FONT_DIR/.version
#              so a re-run doesn't re-download unless upstream actually moves)
#   - theme -> catppuccin/konsole @ main (2 KB, compared with cmp each run)
#
# All userspace: fonts land in ~/.local/share/fonts, the profile and color
# scheme in ~/.local/share/konsole. No sudo, nothing written under /usr.
#
# Note: Konsole has NO fallback font chain (its profile only has `Font` and
# `EmojiFont`), so the profile must point at a Nerd *patched* build — the plain
# Google Sans Code from Google Fonts has no icons and fastfetch would show tofu.

FONT_FAMILY := "GoogleSansCode Nerd Font Mono"
FONT_SIZE := "13"
# QFont::toString() form, exactly as Konsole stores it in the profile.
FONT_SPEC := FONT_FAMILY + "," + FONT_SIZE + ",-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"

# Nerd Fonts ships only the Mono/Propo/plain families; upstream's statics are
# unhinted, so the patched build is also the practical choice.
NF_API := "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
NF_ASSET := "GoogleSansCode.tar.xz"

SCHEME_NAME := "Catppuccin-Macchiato"
# Konsole derives the scheme's name from the FILE name, hence the capitalised target.
SCHEME_URL := "https://raw.githubusercontent.com/catppuccin/konsole/main/themes/catppuccin-macchiato.colorscheme"

KONSOLE_DIR := env("HOME") / ".local/share/konsole"
FONT_DIR := env("HOME") / ".local/share/fonts/GoogleSansCodeNFM"
PROFILE := KONSOLE_DIR / "Fish.profile"
SCHEME_FILE := KONSOLE_DIR / (SCHEME_NAME + ".colorscheme")

# The icons ~/.config/fastfetch/config.jsonc draws — verify-konsole checks these.
ICON_CODEPOINTS := "f007 f01c5 f0150 f013 f01c4 f05b2 e795 f489 f035b e80a f0322"


# Download the Nerd-patched Google Sans Code Mono build into ~/.local/share/fonts
_install-google-font:
    #!/usr/bin/env bash
    set -euo pipefail

    # Ask upstream which release is current. If the API is unreachable (offline,
    # rate limited) the tag stays empty and we fall back to the version-less
    # /releases/latest/ URL, re-downloading rather than silently skipping.
    LATEST_TAG="$(curl -fsSL --retry 3 {{NF_API}} 2>/dev/null \
        | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p')" || LATEST_TAG=""

    INSTALLED="$(cat {{FONT_DIR}}/.version 2>/dev/null || true)"

    if [ -n "$LATEST_TAG" ] && [ "$INSTALLED" = "$LATEST_TAG" ]; then
        echo "{{FONT_FAMILY}} $LATEST_TAG already installed."
        exit 0
    fi

    if [ -n "$LATEST_TAG" ]; then
        URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${LATEST_TAG}/{{NF_ASSET}}"
        echo "Downloading Google Sans Code Nerd Font ${LATEST_TAG}…"
    else
        URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/{{NF_ASSET}}"
        echo "Downloading the latest Google Sans Code Nerd Font (release API unavailable)…"
    fi

    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT

    curl -fL --retry 3 -o "$TMP/google-sans-code.tar.xz" "$URL"

    echo "Extracting the Mono variants…"
    mkdir -p {{FONT_DIR}}
    tar -xJf "$TMP/google-sans-code.tar.xz" -C {{FONT_DIR}} --wildcards 'GoogleSansCodeNerdFontMono-*.ttf'

    # Record what we actually took, so the next run can skip the download.
    if [ -n "$LATEST_TAG" ]; then
        printf '%s\n' "$LATEST_TAG" > {{FONT_DIR}}/.version
    fi

    fc-cache -f {{FONT_DIR}}
    echo "Installed $(find {{FONT_DIR}} -name '*.ttf' | wc -l) font files."


# Install (or refresh) the Catppuccin Macchiato color scheme
_install-konsole-theme:
    #!/usr/bin/env bash
    set -euo pipefail

    TMP="$(mktemp)"
    trap 'rm -f "$TMP"' EXIT

    echo "Fetching Catppuccin Macchiato…"
    curl -fsSL --retry 3 -o "$TMP" {{SCHEME_URL}}

    mkdir -p {{KONSOLE_DIR}}
    if [ -f {{SCHEME_FILE}} ] && cmp -s "$TMP" {{SCHEME_FILE}}; then
        echo "{{SCHEME_NAME}} already up to date."
    else
        install -m644 "$TMP" {{SCHEME_FILE}}
        echo "Installed {{SCHEME_FILE}}"
    fi


# Write the Fish profile (font + scheme) and point Konsole's default profile at it
_install-konsole-profile:
    #!/usr/bin/env bash
    set -euo pipefail

    mkdir -p {{KONSOLE_DIR}}

    TMP="$(mktemp)"
    trap 'rm -f "$TMP"' EXIT

    # Built with printf (not a heredoc) so every line stays indented inside the recipe.
    {
        printf '[Appearance]\n'
        printf 'ColorScheme={{SCHEME_NAME}}\n'
        printf 'Font={{FONT_SPEC}}\n'
        printf '\n'
        printf '[General]\n'
        printf 'Name=Fish\n'
        printf 'Parent=FALLBACK/\n'
    } > "$TMP"

    if [ -f {{PROFILE}} ] && cmp -s "$TMP" {{PROFILE}}; then
        echo "Fish.profile already up to date."
    else
        if [ -f {{PROFILE}} ]; then
            cp {{PROFILE}} {{PROFILE}}.bak
            echo "Backed up the previous profile to {{PROFILE}}.bak"
        fi
        install -m644 "$TMP" {{PROFILE}}
        echo "Wrote {{PROFILE}}"
    fi

    CURRENT="$(kreadconfig6 --file konsolerc --group 'Desktop Entry' --key DefaultProfile 2>/dev/null || true)"
    if [ "$CURRENT" != "Fish.profile" ]; then
        kwriteconfig6 --file konsolerc --group 'Desktop Entry' --key DefaultProfile Fish.profile
        echo "Set Konsole's default profile to Fish.profile."
    else
        echo "Konsole already defaults to Fish.profile."
    fi


# Full Konsole setup: Nerd font + Catppuccin Macchiato scheme + the Fish profile
setup-konsole: _install-google-font _install-konsole-theme _install-konsole-profile
    @echo "Done — restart Konsole for the font and scheme to apply (just verify-konsole to check)."


# Check the font, scheme and profile, plus fastfetch icon glyph coverage
verify-konsole:
    #!/usr/bin/env bash
    set -euo pipefail

    # Counted rather than piped into `grep -q`: with pipefail, grep exiting early
    # hands fc-list a SIGPIPE (141) and the test fails on an installed font.
    FOUND="$(fc-list "{{FONT_FAMILY}}" | wc -l)"
    if [ "$FOUND" -gt 0 ]; then
        echo "Font '{{FONT_FAMILY}}' installed ✓ ($(cat {{FONT_DIR}}/.version 2>/dev/null || echo 'version unknown'))"
    else
        echo "WARNING: font '{{FONT_FAMILY}}' is NOT installed."
    fi

    if [ -f {{SCHEME_FILE}} ]; then
        echo "Color scheme {{SCHEME_NAME}} present ✓"
    else
        echo "WARNING: {{SCHEME_FILE}} is missing."
    fi

    if grep -q "^Font={{FONT_FAMILY}}" {{PROFILE}} 2>/dev/null; then
        echo "Fish.profile uses {{FONT_FAMILY}} ✓"
    else
        echo "WARNING: Fish.profile is missing or names another font."
    fi

    MISSING=()
    for cp in {{ICON_CODEPOINTS}}; do
        if [ "$(fc-list "{{FONT_FAMILY}}:charset=$cp" | wc -l)" -eq 0 ]; then
            MISSING+=("U+${cp^^}")
        fi
    done
    if [ ${#MISSING[@]} -eq 0 ]; then
        echo "Nerd Font glyph coverage for the fastfetch icons ✓"
    else
        echo "WARNING: missing glyphs: ${MISSING[*]}"
    fi
