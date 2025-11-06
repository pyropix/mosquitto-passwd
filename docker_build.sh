#!/bin/sh
echo "WARNING: This script is deprecated. Please use ./build.sh instead."
echo "The new build.sh script supports multi-platform builds with Docker Buildx."
echo ""
echo "Running legacy build for linux/amd64 only..."
echo ""

docker build --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')  --build-arg VCS_REF=$(git rev-parse --short HEAD) --build-arg BUILD_VERSION="0.2" -t burkhardm/mosquitto-passwd:0.2 -t burkhardm/mosquitto-passwd:latest .
