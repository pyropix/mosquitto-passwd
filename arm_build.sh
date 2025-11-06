#!/bin/sh
echo "WARNING: This script is deprecated. Please use ./build.sh instead."
echo "The new build.sh script supports multi-platform builds with Docker Buildx."
echo ""
echo "Example: ./build.sh --platforms linux/arm64,linux/arm/v7"
echo ""
echo "Running legacy ARM build..."
echo ""

docker build --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')  --build-arg VCS_REF=$(git rev-parse --short HEAD) --build-arg BUILD_VERSION="0.2" -t burkhardm/mosquitto-passwd:arm-latest -t burkhardm/mosquitto-passwd:arm-0.2 .
