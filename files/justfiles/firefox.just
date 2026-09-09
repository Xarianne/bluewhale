# ------------------------------------------------------------------------------
# Firefox (Mozilla tarball)
# ------------------------------------------------------------------------------

# Install Firefox from the official Mozilla tarball into ~/Apps, symlink it
# into ~/.local/bin, and create a desktop entry. Re-run to reinstall/upgrade.
[group('apps')]
install-firefox:
    #!/usr/bin/bash
    set -euo pipefail

    APP_DIR="$HOME/Apps/firefox"
    BIN_DIR="$HOME/.local/bin"
    URL="https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT

    echo "Downloading latest Firefox tarball..."
    curl --proto '=https' --tlsv1.2 -fSL --progress-bar -o "$TMP_DIR/firefox.tar.xz" "$URL"

    echo "Extracting..."
    tar -xJf "$TMP_DIR/firefox.tar.xz" -C "$TMP_DIR"

    echo "Installing to $APP_DIR..."
    mkdir -p "$HOME/Apps"
    rm -rf "$APP_DIR"
    mv "$TMP_DIR/firefox" "$APP_DIR"

    echo "Linking into $BIN_DIR..."
    mkdir -p "$BIN_DIR"
    ln -sfn "$APP_DIR/firefox" "$BIN_DIR/firefox"

    echo "Creating desktop entry..."
    mkdir -p "$HOME/.local/share/applications" "$HOME/.local/share/icons/hicolor/128x128/apps"
    cp "$APP_DIR/browser/chrome/icons/default/default128.png" \
       "$HOME/.local/share/icons/hicolor/128x128/apps/firefox.png"
    cat > "$HOME/.local/share/applications/firefox.desktop" <<EOF
    [Desktop Entry]
    Name=Firefox
    GenericName=Web Browser
    Comment=Browse the Web
    Exec=$APP_DIR/firefox %u
    Icon=firefox
    Terminal=false
    Type=Application
    MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
    Categories=Network;WebBrowser;
    Keywords=web;browser;internet;
    StartupNotify=true
    StartupWMClass=firefox
    EOF

    echo "Firefox installed: $($BIN_DIR/firefox --version)"
    echo "Profiles live in ~/.mozilla (untouched)."
