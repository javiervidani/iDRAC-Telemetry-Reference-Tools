#!/bin/bash
#
# Master script to run complete iDRAC Telemetry stack with Victoria Metrics
# This includes all core services + Victoria Metrics database and pump
#
# Usage: ./run-all.sh
#
# Environment variables:
#   CONFIG_DIR    - Path to config directory
#   DATA_DIR      - Path to data directory
#   IDRAC_SERVERS - Comma-separated list of iDRAC IPs (creates config.ini)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_COMPOSE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration
CONFIG_DIR="${CONFIG_DIR:-$PROJECT_DIR/config-files}"
DATA_DIR="${DATA_DIR:-$SCRIPT_DIR/data}"

# Ensure directories exist
mkdir -p "$CONFIG_DIR"
mkdir -p "$CONFIG_DIR/.certs"
mkdir -p "$DATA_DIR"

echo ""
echo "======================================================"
echo "iDRAC Telemetry Reference Tools - All Services"
echo "======================================================"
echo ""

# Check if config.ini exists and is properly configured
if [[ ! -f "$CONFIG_DIR/config.ini" ]]; then
    echo "⚠ No config.ini found. Creating template..."
    cat > "$CONFIG_DIR/config.ini" << 'EOF'
[General]
StompHost=activemq
StompPort=61613

[Services]
; Add your iDRAC servers here
; Format: Types=iDRAC (repeated for each server)
;         IPs=192.168.1.100,192.168.1.101,...
Types=iDRAC
IPs=192.168.1.100

; Add credentials for each iDRAC server
[192.168.1.100]
username=admin
password=password

; Example: Add more servers
; [192.168.1.101]
; username=admin
; password=password
EOF
    echo "✓ Created $CONFIG_DIR/config.ini"
    echo ""
    echo "⚠ IMPORTANT: Edit the config.ini file with your iDRAC server details:"
    echo "   Location: $CONFIG_DIR/config.ini"
    echo ""
    read -p "Press Enter to continue, or Ctrl+C to edit config.ini first..."
fi

echo "Configuration:"
echo "  Config: $CONFIG_DIR/config.ini"
echo "  Data:   $DATA_DIR"
echo ""

# Verify iDRAC servers are configured
if ! grep -q "^IPs=" "$CONFIG_DIR/config.ini"; then
    echo "✗ Error: No IPs configured in config.ini"
    echo "  Please add iDRAC server IPs to: $CONFIG_DIR/config.ini"
    exit 1
fi

CONFIGURED_IPS=$(grep "^IPs=" "$CONFIG_DIR/config.ini" | cut -d= -f2)
echo "Configured iDRAC servers: $CONFIGURED_IPS"
echo ""

# Start services
echo "Starting services..."
echo "  - Core services (activemq, mysql, configui, dbdiscauth, redfishread)"
echo "  - Victoria Metrics database and pump"
echo ""

cd "$PROJECT_DIR"

export PWD="$PROJECT_DIR"

# Generate stable secrets on first run, reuse on subsequent runs
ENV_FILE="$DOCKER_COMPOSE_DIR/.env"
[ -f "$ENV_FILE" ] && . "$ENV_FILE"
export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-$(uuidgen -r)}
export MYSQL_PASSWORD=${MYSQL_PASSWORD:-$(uuidgen -r)}
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

# Persist so values survive restarts
{
  echo "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}"
  echo "MYSQL_PASSWORD=${MYSQL_PASSWORD}"
  echo "USER_ID=${USER_ID}"
  echo "GROUP_ID=${GROUP_ID}"
} > "$ENV_FILE"

# Silence warnings for unused pump variables
export OTEL_COLLECTOR= OTEL_CACERT= OTEL_CLIENT_CERT= OTEL_CLIENT_KEY= OTEL_SKIP_VERIFY=
export SPLUNK_HEC_URL= SPLUNK_HEC_KEY= SPLUNK_HEC_INDEX=
export KAFKA_BROKER= KAFKA_TOPIC= KAFKA_ALERT_TOPIC= KAFKA_PARTITION=
export KAFKA_CACERT= KAFKA_CLIENT_CERT= KAFKA_CLIENT_KEY= KAFKA_SKIP_VERIFY=
export INCLUDE_ALERTS=

# Grafana: hardcoded admin credentials
export GF_SECURITY_ADMIN_USER=admin
export GF_SECURITY_ADMIN_PASSWORD=admin123
export GF_INSTALL_PLUGINS=   # disable plugin download (offline server)

# Auto-provision VictoriaMetrics datasource in Grafana
PROV_DIR="$DOCKER_COMPOSE_DIR/grafana-provisioning/datasources"
mkdir -p "$PROV_DIR"
cat > "$PROV_DIR/victoriametrics.yaml" << 'EOF'
apiVersion: 1
datasources:
  - name: VictoriaMetrics
    type: prometheus
    access: proxy
    url: http://victoriametrics:8428
    isDefault: true
    editable: false
EOF

# Run with victoria-db, victoria-pump, and grafana profiles
docker compose \
    -f "$DOCKER_COMPOSE_DIR/docker-compose.yml" \
    -f "$SCRIPT_DIR/docker-compose.override.yml" \
    --profile core \
    --profile victoria-db \
    --profile victoria-pump \
    --profile grafana \
    up -d

echo ""
echo "======================================================"
echo "✓ All services started successfully!"
echo "======================================================"
echo ""
echo "Services Status:"
docker compose -f "$DOCKER_COMPOSE_DIR/docker-compose.yml" ps
echo ""
echo "Web Interfaces:"
echo "  • ConfigUI:         http://localhost:8080"
echo "  • ActiveMQ:         http://localhost:8161"
echo "  • Victoria Metrics: http://localhost:8428"
echo "  • Grafana:          http://localhost:3000  (admin / admin123)"
echo ""
echo "Useful Commands:"
echo "  • View logs:       docker compose -f docker-compose-files/docker-compose.yml logs -f"
echo "  • Stop services:   docker compose -f docker-compose-files/docker-compose.yml down"
echo "  • Restart service: docker compose -f docker-compose-files/docker-compose.yml restart <service-name>"
echo ""
echo "Configuration:"
echo "  • Edit iDRAC servers: $CONFIG_DIR/config.ini"
echo "  • Data directory: $DATA_DIR"
echo ""
