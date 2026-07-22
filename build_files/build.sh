#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Modifications are split into subfiles, similar in spirit to a BlueBuild
### recipe's modules -- each one handles one concern and is sourced here so
### build.sh acts as the single entrypoint.

SCRIPT_DIR="$(dirname "$0")"

source "${SCRIPT_DIR}/packages/copr.sh"
source "${SCRIPT_DIR}/packages/packages.sh"
source "${SCRIPT_DIR}/modules/kargs.sh"
source "${SCRIPT_DIR}/modules/systemd.sh"
