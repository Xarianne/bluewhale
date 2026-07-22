#!/bin/bash

set -ouex pipefail

# Masked globally since there's no logged-in user session during the build.
systemctl --global mask app-org.kde.xwaylandvideobridge@autostart.service

# input-remapper still works on demand via GUI or CLI; this only prevents
# the autoload service from running at login
systemctl --global mask 'app-input\x2dremapper\x2dautoload@autostart.service'
