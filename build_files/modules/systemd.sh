#!/bin/bash

set -ouex pipefail

# Masked globally since there's no logged-in user session during the build.
systemctl --global mask app-org.kde.xwaylandvideobridge@autostart.service
