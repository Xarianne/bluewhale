#!/usr/bin/bash
set -eoux pipefail

echo "Adding Antigravity Repo..."
cat << EOL > /etc/yum.repos.d/antigravity.repo
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL

echo "Building dnf cache and installing Antigravity..."
dnf makecache
dnf install -y antigravity
