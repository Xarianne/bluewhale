#!/usr/bin/bash
set -eoux pipefail

# Install official Ollama binary + ROCm backend into /usr/ (ostree-managed location)
# Bundles ROCm 7.2 with gfx1200/gfx1201 support for RX 9070
# Avoids the Fedora package being stuck on 0.12.11

INSTALL_DIR="/usr"

# Download and extract base Ollama
echo "Downloading ollama-linux-amd64 base..."
curl -fL --progress-bar -o /tmp/ollama-base.tar.zst \
  "https://ollama.com/download/ollama-linux-amd64.tar.zst"
zstd -d /tmp/ollama-base.tar.zst -o /tmp/ollama-base.tar

# Extract to /usr/ (the tarball has lib/ollama/ and bin/ at root)
mkdir -p "${INSTALL_DIR}/lib/ollama" "${INSTALL_DIR}/bin"
tar -xf /tmp/ollama-base.tar -C "${INSTALL_DIR}"
rm -f /tmp/ollama-base.tar /tmp/ollama-base.tar.zst

# Download and extract ROCm backend
echo "Downloading ollama-linux-amd64-rocm..."
curl -fL --progress-bar -o /tmp/ollama-rocm.tar.zst \
  "https://ollama.com/download/ollama-linux-amd64-rocm.tar.zst"
zstd -d /tmp/ollama-rocm.tar.zst -o /tmp/ollama-rocm.tar
tar -xf /tmp/ollama-rocm.tar -C "${INSTALL_DIR}"
rm -f /tmp/ollama-rocm.tar /tmp/ollama-rocm.tar.zst

# Remove CUDA backends (no NVIDIA GPU, saves ~500MB)
rm -rf "${INSTALL_DIR}/lib/ollama/cuda_v12" "${INSTALL_DIR}/lib/ollama/cuda_v13"

# Remove Vulkan backend if present (we have ROCm)
rm -rf "${INSTALL_DIR}/lib/ollama/vulkan"

# Ensure binary is executable
chmod +x "${INSTALL_DIR}/bin/ollama"

echo "Ollama installed with ROCm backend to ${INSTALL_DIR}"