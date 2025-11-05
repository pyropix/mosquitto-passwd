#!/bin/sh
set -e

# Check if required environment variables are set
if [ -z "$DOCKER_USERNAME" ]; then
  echo "Error: DOCKER_USERNAME environment variable is not set" >&2
  exit 1
fi

if [ -z "$DOCKER_PASSWORD" ]; then
  echo "Error: DOCKER_PASSWORD environment variable is not set" >&2
  exit 1
fi

# Login using environment variables
echo "$DOCKER_PASSWORD" | docker login --username="$DOCKER_USERNAME" --password-stdin

# Push images
docker push burkhardm/mosquitto-passwd:arm-latest
docker push burkhardm/mosquitto-passwd:arm-0.2

# Logout
docker logout
