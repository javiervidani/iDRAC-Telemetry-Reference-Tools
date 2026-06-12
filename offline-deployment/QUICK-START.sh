#!/bin/bash
#
# QUICK START GUIDE
# Fast deployment for offline servers with pre-built images
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
CONFIG_DIR="$PROJECT_DIR/config-files"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
 _____ _____ _____  ___   _____           _           _               
|_   _|  __ \|  __ \/ _ \ / ____|         | |         | |              
  | | | |  | | |__) | | | | |     ___ ___ | | | ___  __| | ___  _ __ 
  | | | |  | |  _  /| | | | |    / __/ _ \| | |/ _ \/ _` |/ _ \| '__|
  | | | |__| | | \ \| |_| | |___| (_| (_) | | |  __/ (_| | (_) | |   
  |_| |_____/|_|  \_\\___/ \_____\___\___/|_|_|\___|\__,_|\___/|_|   
                                                                       
  Telemetry Collector - Offline Deployment
EOF
echo -e "${NC}"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "✗ Docker is not installed"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "✗ Docker Compose is not installed"
    exit 1
fi

echo "✓ Docker is installed"
echo "✓ Docker Compose is installed"
echo ""

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"
mkdir -p "$CONFIG_DIR/.certs"

# Create sample config if not exists
if [[ ! -f "$CONFIG_DIR/config.ini" ]]; then
    echo "Creating config template in: $CONFIG_DIR/config.ini"
    cp "$SCRIPT_DIR/config.ini.template" "$CONFIG_DIR/config.ini"
    echo ""
    echo "⚠ IMPORTANT: Configure your iDRAC servers:"
    echo "   Edit: $CONFIG_DIR/config.ini"
    echo ""
fi

echo -e "${BLUE}Quick Start Commands:${NC}"
echo ""
echo "1. Start all services:"
echo -e "   ${GREEN}./docker-compose-files/run-all.sh${NC}"
echo ""
echo "2. Check service status:"
echo -e "   ${GREEN}docker-compose -f docker-compose-files/docker-compose.yml ps${NC}"
echo ""
echo "3. View service logs:"
echo -e "   ${GREEN}docker-compose -f docker-compose-files/docker-compose.yml logs -f${NC}"
echo ""
echo "4. Stop all services:"
echo -e "   ${GREEN}docker-compose -f docker-compose-files/docker-compose.yml down${NC}"
echo ""
echo "5. Edit iDRAC server configuration:"
echo -e "   ${GREEN}nano $CONFIG_DIR/config.ini${NC}"
echo ""
echo "6. Full deployment with setup:"
echo -e "   ${GREEN}./docker-compose-files/deploy-offline.sh full${NC}"
echo ""

echo "Web Interfaces:"
echo "  • ConfigUI:        http://localhost:8812"
echo "  • ActiveMQ:        http://localhost:8161"
echo "  • Victoria Metrics: http://localhost:8428"
echo ""
