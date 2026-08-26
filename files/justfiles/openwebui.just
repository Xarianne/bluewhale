# ------------------------------------------------------------------------------
# Open WebUI (Podman)
# ------------------------------------------------------------------------------

# Start Open WebUI and Open Terminal via rootless Podman
[group('AI')]
start-open-webui: start-open-terminal
    @echo "Booting Open WebUI container..."
    @if podman ps -q --filter name=^open-webui$ | grep -q .; then \
        echo "Open WebUI is already running."; \
    else \
        podman run -d --rm --network=host \
            -v open-webui:/app/backend/data \
            --name open-webui \
            ghcr.io/open-webui/open-webui:main; \
    fi
    @echo "Access Open WebUI via your browser at http://127.0.0.1:8080/"
    @echo "Open Terminal API available at http://127.0.0.1:8000/"

# Stop Open WebUI and Open Terminal gracefully
[group('AI')]
stop-open-webui: stop-open-terminal
    @echo "Stopping Open WebUI container..."
    @podman rm -f open-webui >/dev/null 2>&1 || true

# Update Open WebUI and Open Terminal (pull latest images and restart)
[group('AI')]
update-open-webui:
    @echo "Pulling latest Open WebUI image..."
    @podman pull ghcr.io/open-webui/open-webui:main
    @echo "Pulling latest Open Terminal image..."
    @podman pull ghcr.io/open-webui/open-terminal
    @echo "Restarting Open WebUI + Open Terminal..."
    @just stop-open-webui
    @just start-open-webui

# ------------------------------------------------------------------------------
# Open Terminal (Podman)
# ------------------------------------------------------------------------------

# Start Open Terminal via rootless Podman (called automatically by start-open-webui)
[group('AI')]
start-open-terminal:
    @echo "Booting Open Terminal container..."
    @if podman ps -q --filter name=^open-terminal$ | grep -q .; then \
        echo "Open Terminal is already running."; \
    else \
        podman run -d --rm -p 8000:8000 \
            -v open-terminal:/home/user \
            -e OPEN_TERMINAL_API_KEY=open-terminal-local \
            --name open-terminal \
            ghcr.io/open-webui/open-terminal; \
    fi

# Stop Open Terminal gracefully (called automatically by stop-open-webui)
[group('AI')]
stop-open-terminal:
    @echo "Stopping Open Terminal container..."
    @podman rm -f open-terminal >/dev/null 2>&1 || true
