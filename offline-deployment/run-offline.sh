#!/bin/bash
#
# Script to run Docker containers offline with proper configuration
# This script handles volume mounts for config files
#
# Usage: ./run-offline.sh [--victoria-db] [--prometheus-pump] [--influx-pump] etc.
#
# Environment variables you can set:
#   CONFIG_DIR    - Path to directory containing config.ini (default: ../config-files)
#   DATA_DIR      - Path to directory for persistent data (default: ./data)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_COMPOSE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration directories
CONFIG_DIR="${CONFIG_DIR:-$PROJECT_DIR/config-files}"
DATA_DIR="${DATA_DIR:-$SCRIPT_DIR/data}"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"
mkdir -p "$DATA_DIR"

# Create default config.ini if it doesn't exist
if [[ ! -f "$CONFIG_DIR/config.ini" ]]; then
    echo "Creating default config.ini in $CONFIG_DIR"
    cat > "$CONFIG_DIR/config.ini" << 'EOF'
[General]
StompHost=activemq
StompPort=61613

[Services]
; Comma-separated list of iDRAC server types (iDRAC for Dell servers)
Types=iDRAC

; Comma-separated list of iDRAC server IP addresses or hostnames
IPs=192.168.1.100

; For each IP address defined above, create a [section] with credentials
[192.168.1.100]
username=admin
password=password123

; Add more servers as needed:
; [192.168.1.101]
; username=admin
; password=password123
EOF
    echo "  ✓ Created default config.ini"
    echo "  ⚠ Please edit this file with your iDRAC server details"
fi

# Create .certs directory if needed
mkdir -p "$CONFIG_DIR/.certs"

echo ""
echo "======================================================"
echo "Running iDRAC Telemetry Stack (Offline Mode)"
echo "======================================================"
echo "Config directory: $CONFIG_DIR"
echo "Data directory:   $DATA_DIR"
echo ""

# Parse arguments
COMPOSE_ARGS="--profile core"
for arg in "$@"; do
    case "$arg" in
        --victoria-db|--victoria-pump|--prometheus-pump|--influx-pump|--splunk-pump|--kafka-pump|--elk-pump|--timescale-pump|--grafana)
            COMPOSE_ARGS="$COMPOSE_ARGS --profile ${arg#--}"
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --victoria-db         Start with VictoriaMetrics database"
            echo "  --victoria-pump       Start victoria metrics pump"
            echo "  --prometheus-pump     Start prometheus pump"
            echo "  --influx-pump         Start influx pump"
            echo "  --splunk-pump         Start splunk pump"
            echo "  --kafka-pump          Start kafka pump"
            echo "  --elk-pump            Start elk pump"
            echo "  --timescale-pump      Start timescale pump"
            echo "  --grafana             Start grafana dashboard"
            echo ""
            echo "Environment variables:"
            echo "  CONFIG_DIR  - Config directory (default: $CONFIG_DIR)"
            echo "  DATA_DIR    - Data directory (default: $DATA_DIR)"
            echo ""
            exit 0
            ;;
        *)
            COMPOSE_ARGS="$COMPOSE_ARGS $arg"
            ;;
    esac
done

echo "Starting services with profiles: $COMPOSE_ARGS"
echo ""

# Run docker-compose with proper volume mounts
cd "$PROJECT_DIR"

export PWD="$PROJECT_DIR"

docker-compose \
    -f "$DOCKER_COMPOSE_DIR/docker-compose.yml" \
    $COMPOSE_ARGS \
    -v "$CONFIG_DIR/config.ini:/etc/telemetry/config.ini:ro" \
    -v "$CONFIG_DIR/.certs:/extrabin/certs:rw" \
    -v "$DATA_DIR/mysqldb:/var/lib/mysql:rw" \
    -v "$DATA_DIR/victoria-metrics:/victoria-metrics-data:rw" \
    up -d

echo ""
echo "======================================================"
echo "Services started successfully!"
echo "======================================================"
echo ""
echo "Configuration:"
echo "  - Config file: $CONFIG_DIR/config.ini"
echo "  - Data dir: $DATA_DIR"
echo ""
echo "Web Interfaces:"
echo "  - ConfigUI: http://localhost:8812"
echo "  - ActiveMQ: http://localhost:8161"
echo ""
echo "View logs:"
echo "  docker-compose -f docker-compose-files/docker-compose.yml logs -f"
echo ""
echo "Stop services:"
echo "  docker-compose -f docker-compose-files/docker-compose.yml down"
echo ""
