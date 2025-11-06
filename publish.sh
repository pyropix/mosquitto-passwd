#!/bin/bash
set -euo pipefail

# Unified publish script using Docker Buildx
# Replaces: docker_publish.sh, arm_publish.sh

# Check if required environment variables are set
if [ -z "${DOCKER_USERNAME:-}" ]; then
  echo "Error: DOCKER_USERNAME environment variable is not set" >&2
  exit 1
fi

if [ -z "${DOCKER_PASSWORD:-}" ]; then
  echo "Error: DOCKER_PASSWORD environment variable is not set" >&2
  exit 1
fi

# Configuration
IMAGE_NAME="${IMAGE_NAME:-burkhardm/mosquitto-passwd}"
VERSION="${VERSION:-0.2}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64,linux/arm/v7}"

echo "======================================"
echo "Publishing Docker Images"
echo "======================================"
echo "Image: $IMAGE_NAME"
echo "Version: $VERSION"
echo "Platforms: $PLATFORMS"
echo "======================================"
echo ""

# Login to Docker Hub
echo "Logging in to Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login --username="$DOCKER_USERNAME" --password-stdin

# Build and push using unified build script
echo ""
echo "Building and pushing images..."
./build.sh --push --version "$VERSION" --platforms "$PLATFORMS" --name "$IMAGE_NAME"

# Logout
echo ""
echo "Logging out from Docker Hub..."
docker logout

echo ""
echo "======================================"
echo "Publish completed successfully!"
echo "======================================"
