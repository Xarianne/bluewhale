#!/usr/bin/env bash
set -euo pipefail

echo "Fetching latest Goose RPM URL..."
RPM_URL=$(curl -s https://api.github.com/repos/aaif-goose/goose/releases/latest | jq -r '.assets[] | select(.name | endswith(".x86_64.rpm")) | .browser_download_url')

if [ -n "$RPM_URL" ] && [ "$RPM_URL" != "null" ]; then
  echo "Installing latest Goose RPM: $RPM_URL"
  dnf install -y "$RPM_URL"
else
  echo "Failed to fetch Goose RPM URL"
  exit 1
fi
