#!/bin/bash

set -ouex pipefail

echo "::group:: Configure kernel arguments"

mkdir -p /usr/lib/bootc/kargs.d
cat <<EOF >> /usr/lib/bootc/kargs.d/10-amdgpu.toml
kargs = ["amdgpu.ppfeaturemask=0xffffffff"]
match-architectures = ["x86_64"]
EOF

echo "Kernel arguments configured"
echo "::endgroup::"

echo "kargs configuration complete"
