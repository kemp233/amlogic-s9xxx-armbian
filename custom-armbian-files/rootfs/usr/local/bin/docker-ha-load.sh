#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAR="/opt/docker-images/ha.tar.gz"
IMAGE_TAG="ghcr.io/home-assistant/home-assistant:stable"
LOADED_MARKER="/opt/docker-images/.ha-loaded"

# Already loaded once — skip
if [[ -f "${LOADED_MARKER}" ]]; then
    echo "[docker-ha-load] HA image already loaded, exiting."
    exit 0
fi

if [[ ! -f "${IMAGE_TAR}" ]]; then
    echo "[docker-ha-load] ${IMAGE_TAR} not found, skipping."
    exit 0
fi

echo "[docker-ha-load] Loading ${IMAGE_TAR}..."
if zcat "${IMAGE_TAR}" | docker load; then
    echo "[docker-ha-load] Image loaded successfully: ${IMAGE_TAG}"
    touch "${LOADED_MARKER}"
else
    echo "[docker-ha-load] ERROR: failed to load image"
    exit 1
fi