#!/bin/bash
#
# Script to load Docker images from tar files
# Usage: ./load-docker-images.sh /path/to/saved/images
#

set -e

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 /path/to/saved/images"
    echo ""
    echo "This script loads all Docker images from tar files"
    echo "created by save-docker-images.sh"
    exit 1
fi

IMAGE_DIR="$1"

if [[ ! -d "$IMAGE_DIR" ]]; then
    echo "Error: Directory not found: $IMAGE_DIR"
    exit 1
fi

# Count tar files
TAR_COUNT=$(ls "$IMAGE_DIR"/*.tar.gz 2>/dev/null | wc -l)

if [[ $TAR_COUNT -eq 0 ]]; then
    echo "Error: No .tar.gz files found in $IMAGE_DIR"
    exit 1
fi

echo "Loading Docker images from: $IMAGE_DIR"
echo "============================================"
echo "Found $TAR_COUNT image files to load"
echo ""

# Load all images
for tar_file in "$IMAGE_DIR"/*.tar.gz; do
    filename=$(basename "$tar_file")
    echo "Loading: $filename"
    
    gunzip -c "$tar_file" | docker load
    
    echo "  ✓ Loaded"
    echo ""
done

echo "============================================"
echo "All images loaded successfully!"
echo ""
docker images | grep -E "idrac-telemetry|mysql|activemq|victoria-metrics"
