#!/bin/bash
#
# Script to save all Docker images to tar files for offline deployment
# Usage: ./save-docker-images.sh [output-directory]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_COMPOSE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="${1:-.}"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Saving Docker images to: $OUTPUT_DIR"
echo "============================================"

# List of images to save
# Built images (will be built if not present)
IMAGES=(
    "mysql:latest"
    "rmohr/activemq:latest"
    "victoriametrics/victoria-metrics:v1.121.0"
)

# Built images - these need to be built first
BUILT_IMAGES=(
    "idrac-telemetry-reference-tools/redfishread:latest"
    "idrac-telemetry-reference-tools/configui:latest"
    "idrac-telemetry-reference-tools/victoriapump:latest"
    "idrac-telemetry-reference-tools/dbdiscauth:latest"
)

# First, build the custom images if they don't exist
echo ""
echo "Building custom images..."
cd "$PROJECT_DIR"

for img in "${BUILT_IMAGES[@]}"; do
    if ! docker image inspect "$img" > /dev/null 2>&1; then
        echo "Image $img not found. Building..."
        "$DOCKER_COMPOSE_DIR/compose.sh" --build start
        break
    fi
done

cd "$SCRIPT_DIR"

# Save all images
ALL_IMAGES=("${IMAGES[@]}" "${BUILT_IMAGES[@]}")

for img in "${ALL_IMAGES[@]}"; do
    # Replace special characters in image name for filename
    filename=$(echo "$img" | sed 's|/|-|g' | sed 's|:|-|g').tar.gz
    filepath="$OUTPUT_DIR/$filename"
    
    echo ""
    echo "Saving: $img -> $filepath"
    docker save "$img" | gzip > "$filepath"
    
    # Show file size
    size=$(du -h "$filepath" | cut -f1)
    echo "  Size: $size"
done

echo ""
echo "============================================"
echo "All images saved successfully!"
echo "Total images: ${#ALL_IMAGES[@]}"
echo ""
echo "To load images on offline server, use:"
echo "  ./load-docker-images.sh /path/to/saved/images"
