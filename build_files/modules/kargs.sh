#!/bin/bash

set -ouex pipefail

mkdir -p /usr/lib/bootc/kargs.d
cat <<EOF >> /usr/lib/bootc/kargs.d/10-amdgpu.toml
kargs = ["amdgpu.ppfeaturemask=0xffffffff"]
match-architectures = ["x86_64"]
EOF
