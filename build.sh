#!/bin/bash
set -euo pipefail

# Unified build script using Docker Buildx for multi-platform support
# Replaces: docker_build.sh, arm_build.sh

# Configuration
IMAGE_NAME="${IMAGE_NAME:-burkhardm/mosquitto-passwd}"
VERSION="${VERSION:-0.2}"
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Default platforms
DEFAULT_PLATFORMS="linux/amd64,linux/arm64,linux/arm/v7"

# Parse command line arguments
PLATFORMS="${PLATFORMS:-$DEFAULT_PLATFORMS}"
PUSH=false
LOAD=false

usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Build Docker images using buildx for multi-platform support.

OPTIONS:
  -p, --platforms PLATFORMS  Comma-separated list of platforms (default: $DEFAULT_PLATFORMS)
  -v, --version VERSION      Version tag (default: $VERSION)
  -n, --name IMAGE_NAME      Image name (default: $IMAGE_NAME)
  --push                     Push to registry after build
  --load                     Load image to local Docker (single platform only)
  -h, --help                Show this help message

EXAMPLES:
  # Build for all platforms locally (no push)
  $0

  # Build for specific platform and load to local Docker
  $0 --platforms linux/amd64 --load

  # Build and push to registry
  $0 --push

  # Build specific version
  $0 --version 0.3 --push

  # Build for ARM only
  $0 --platforms linux/arm64,linux/arm/v7

ENVIRONMENT VARIABLES:
  IMAGE_NAME    Override default image name
  VERSION       Override default version
  PLATFORMS     Override default platforms

EOF
  exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--platforms)
      PLATFORMS="$2"
      shift 2
      ;;
    -v|--version)
      VERSION="$2"
      shift 2
      ;;
    -n|--name)
      IMAGE_NAME="$2"
      shift 2
      ;;
    --push)
      PUSH=true
      shift
      ;;
    --load)
      LOAD=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# Validate conflicting options
if [ "$PUSH" = true ] && [ "$LOAD" = true ]; then
  echo "Error: Cannot use --push and --load together"
  exit 1
fi

# Validate load with multiple platforms
if [ "$LOAD" = true ]; then
  platform_count=$(echo "$PLATFORMS" | tr ',' '\n' | wc -l)
  if [ "$platform_count" -gt 1 ]; then
    echo "Error: --load only works with a single platform"
    echo "Hint: Use --platforms linux/amd64 (or your desired platform)"
    exit 1
  fi
fi

# Setup buildx
echo "Setting up Docker Buildx..."
if ! docker buildx ls | grep -q multiplatform; then
  docker buildx create --name multiplatform --use
else
  docker buildx use multiplatform
fi

# Build tags
TAGS=(
  "-t ${IMAGE_NAME}:${VERSION}"
  "-t ${IMAGE_NAME}:latest"
)

# Build command
BUILD_CMD="docker buildx build"
BUILD_CMD+=" --platform ${PLATFORMS}"
BUILD_CMD+=" --build-arg BUILD_DATE=${BUILD_DATE}"
BUILD_CMD+=" --build-arg VCS_REF=${VCS_REF}"
BUILD_CMD+=" --build-arg BUILD_VERSION=${VERSION}"

# Add tags
for tag in "${TAGS[@]}"; do
  BUILD_CMD+=" $tag"
done

# Add push or load flag
if [ "$PUSH" = true ]; then
  BUILD_CMD+=" --push"
  echo "Building and pushing to registry..."
elif [ "$LOAD" = true ]; then
  BUILD_CMD+=" --load"
  echo "Building and loading to local Docker..."
else
  echo "Building (no push/load)..."
fi

# Add context
BUILD_CMD+=" ."

# Display build information
echo "======================================"
echo "Image: $IMAGE_NAME"
echo "Version: $VERSION"
echo "Platforms: $PLATFORMS"
echo "Build Date: $BUILD_DATE"
echo "VCS Ref: $VCS_REF"
echo "Push: $PUSH"
echo "Load: $LOAD"
echo "======================================"
echo ""

# Execute build
echo "Executing: $BUILD_CMD"
echo ""
eval "$BUILD_CMD"

echo ""
echo "======================================"
echo "Build completed successfully!"
echo "======================================"

if [ "$PUSH" = true ]; then
  echo ""
  echo "Images pushed to registry:"
  for tag in "${TAGS[@]}"; do
    echo "  ${tag#-t }"
  done
fi

if [ "$LOAD" = true ]; then
  echo ""
  echo "Image loaded to local Docker:"
  docker images | grep "$IMAGE_NAME" | head -2
fi
