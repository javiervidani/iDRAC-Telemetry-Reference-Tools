#!/bin/bash
#
# MASTER DEPLOYMENT SCRIPT
# Orchestrates the complete offline deployment process
#
# Usage: ./deploy-offline.sh --step [1|2|3|4] [OPTIONS]
#
# Step 1: Save images on online server
# Step 2: Load images on offline server
# Step 3: Configure iDRAC servers
# Step 4: Start services
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_COMPOSE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}=====================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=====================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

show_help() {
    cat << EOF
MASTER DEPLOYMENT SCRIPT - iDRAC Telemetry Offline Installation

USAGE: $0 [COMMAND] [OPTIONS]

COMMANDS:
  full                  Run complete deployment (interactive)
  save [OUTPUT_DIR]     Save images to directory (Step 1)
  load [INPUT_DIR]      Load images from directory (Step 2)
  configure             Create/edit config.ini (Step 3)
  start                 Start all services (Step 4)
  status                Show service status
  stop                  Stop all services
  logs [SERVICE]        Show service logs
  help                  Show this help message

EXAMPLES:
  # Complete interactive deployment
  $0 full

  # Step-by-step on online server
  $0 save ./docker-images-backup

  # Step-by-step on offline server
  $0 load ./docker-images-backup
  $0 configure
  $0 start

  # View status
  $0 status
  $0 logs redfishread

EOF
}

cmd_full_deployment() {
    print_header "iDRAC Telemetry - Full Deployment"

    print_info "This will guide you through the complete deployment process"
    print_info "Choose your scenario:"
    echo ""
    echo "  1. Online server (save images)"
    echo "  2. Offline server (load images and run)"
    echo ""
    read -p "Select scenario [1-2]: " scenario

    case $scenario in
        1)
            cmd_save_images "./docker-images-backup"
            print_success "Images saved to: ./docker-images-backup"
            print_info "Copy this directory to your offline server"
            ;;
        2)
            read -p "Enter path to saved images directory: " image_dir
            if [[ ! -d "$image_dir" ]]; then
                print_error "Directory not found: $image_dir"
                exit 1
            fi
            cmd_load_images "$image_dir"
            cmd_configure
            cmd_start
            ;;
        *)
            print_error "Invalid option"
            exit 1
            ;;
    esac
}

cmd_save_images() {
    local output_dir="${1:-.}"
    print_header "Saving Docker Images (Step 1)"
    
    print_info "Saving images to: $output_dir"
    cd "$SCRIPT_DIR"
    
    if [[ ! -x "./save-docker-images.sh" ]]; then
        print_error "Script not executable: save-docker-images.sh"
        exit 1
    fi
    
    ./save-docker-images.sh "$output_dir"
}

cmd_load_images() {
    local input_dir="${1:-.}"
    print_header "Loading Docker Images (Step 2)"
    
    if [[ ! -d "$input_dir" ]]; then
        print_error "Directory not found: $input_dir"
        exit 1
    fi
    
    print_info "Loading images from: $input_dir"
    cd "$SCRIPT_DIR"
    
    if [[ ! -x "./load-docker-images.sh" ]]; then
        print_error "Script not executable: load-docker-images.sh"
        exit 1
    fi
    
    ./load-docker-images.sh "$input_dir"
}

cmd_configure() {
    print_header "Configuration (Step 3)"
    
    CONFIG_DIR="$PROJECT_DIR/config-files"
    CONFIG_FILE="$CONFIG_DIR/config.ini"
    
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$CONFIG_DIR/.certs"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_info "Creating default config.ini"
        cat > "$CONFIG_FILE" << 'EOF'
[General]
StompHost=activemq
StompPort=61613

[Services]
Types=iDRAC
IPs=192.168.1.100

[192.168.1.100]
username=admin
password=password123
EOF
        print_success "Created: $CONFIG_FILE"
    fi
    
    print_warning "IMPORTANT: Edit the configuration file:"
    print_info "File: $CONFIG_FILE"
    echo ""
    echo "Edit with your iDRAC server details, then press Enter..."
    read
    
    if command -v nano &> /dev/null; then
        nano "$CONFIG_FILE"
    elif command -v vi &> /dev/null; then
        vi "$CONFIG_FILE"
    else
        print_warning "No text editor found. Please manually edit: $CONFIG_FILE"
    fi
}

cmd_start() {
    print_header "Starting Services (Step 4)"
    
    cd "$SCRIPT_DIR"
    
    if [[ ! -x "./run-all.sh" ]]; then
        print_error "Script not executable: run-all.sh"
        exit 1
    fi
    
    ./run-all.sh
}

cmd_status() {
    print_header "Service Status"
    cd "$PROJECT_DIR"
    docker-compose -f docker-compose-files/docker-compose.yml ps
}

cmd_stop() {
    print_header "Stopping Services"
    cd "$PROJECT_DIR"
    docker-compose -f docker-compose-files/docker-compose.yml down
    print_success "Services stopped"
}

cmd_logs() {
    local service="${1:-}"
    print_header "Service Logs"
    
    cd "$PROJECT_DIR"
    
    if [[ -z "$service" ]]; then
        docker-compose -f docker-compose-files/docker-compose.yml logs -f
    else
        docker-compose -f docker-compose-files/docker-compose.yml logs -f "$service"
    fi
}

# Main command dispatcher
case "${1:-help}" in
    full)
        cmd_full_deployment
        ;;
    save)
        cmd_save_images "${2:-.}"
        ;;
    load)
        cmd_load_images "${2:-.}"
        ;;
    configure)
        cmd_configure
        ;;
    start)
        cmd_start
        ;;
    status)
        cmd_status
        ;;
    stop)
        cmd_stop
        ;;
    logs)
        cmd_logs "${2:-}"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
