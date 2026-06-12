# Docker Image Offline Deployment - Complete Guide

## What Was Created

I've created a complete set of scripts to save Docker images and run them on an offline server. Here's what you have:

### Scripts in `docker-compose-files/`:

#### 1. **save-docker-images.sh** - Save Images to Disk
```bash
./save-docker-images.sh ./docker-images-backup
```
- Saves all 7 Docker images as compressed .tar.gz files
- Includes automatic building of custom images if needed
- Output size: ~500MB-1GB depending on images
- **Use on**: Online/development server

#### 2. **load-docker-images.sh** - Load Images from Disk
```bash
./load-docker-images.sh /path/to/docker-images-backup
```
- Loads all images from .tar.gz files
- Verifies images were loaded successfully
- **Use on**: Offline server

#### 3. **run-all.sh** - Run Complete Stack
```bash
./run-all.sh
```
- Starts all services with Victoria Metrics
- Core services: ActiveMQ, MySQL, ConfigUI, Redfish reader
- Database: Victoria Metrics
- Data pump: Victoria Metrics pump
- Auto-creates config.ini if missing
- **Use on**: Offline server with loaded images

#### 4. **run-offline.sh** - Custom Configuration
```bash
./run-offline.sh --victoria-db --victoria-pump --prometheus-pump
```
- Start services with custom profiles
- Full control over which components to enable
- Supports volume mounting for config files
- **Use on**: Offline server with custom setup

#### 5. **deploy-offline.sh** - Master Orchestration Script
```bash
./deploy-offline.sh full                    # Interactive full deployment
./deploy-offline.sh save ./images-dir       # Save images
./deploy-offline.sh load ./images-dir       # Load images
./deploy-offline.sh configure               # Setup config
./deploy-offline.sh start                   # Start services
./deploy-offline.sh status                  # Check status
./deploy-offline.sh logs [service]          # View logs
```
- Handles complete deployment workflow
- Color-coded output for easy following
- Interactive menu options
- **Use on**: Either online or offline server

### Configuration Files:

#### **docker-compose-files/config.ini.template**
- Template for iDRAC server configuration
- Shows format for multiple servers with credentials

#### **docker-compose-files/OFFLINE-DEPLOYMENT.md**
- Comprehensive deployment guide
- Troubleshooting tips
- Performance notes
- Backup/restore procedures

---

## Quick Start Workflow

### On Online Server:
```bash
cd docker-compose-files
./save-docker-images.sh ./docker-images-backup
# Copy docker-images-backup/ to offline server via USB/transfer
```

### On Offline Server:
```bash
# Load images
./docker-compose-files/load-docker-images.sh /path/to/docker-images-backup

# Configure iDRAC servers
cp docker-compose-files/config.ini.template config-files/config.ini
# Edit config-files/config.ini with your iDRAC server IPs and credentials

# Start services
./docker-compose-files/run-all.sh
```

---

## Images Being Saved

The scripts handle these 7 Docker images:

**External (Pre-built) Images:**
- `mysql:latest` - Database server (~150MB)
- `rmohr/activemq:latest` - Message broker (~200MB)
- `victoriametrics/victoria-metrics:v1.121.0` - Time-series DB (~100MB)

**Custom Built Images:**
- `idrac-telemetry-reference-tools/redfishread` - iDRAC reader (~400MB)
- `idrac-telemetry-reference-tools/configui` - Web UI (~350MB)
- `idrac-telemetry-reference-tools/victoriapump` - Data pump (~350MB)
- `idrac-telemetry-reference-tools/dbdiscauth` - DB/Auth service (~350MB)

**Total size**: ~1.5-2GB (compressed as .tar.gz)

---

## Configuration File Format

Create `config-files/config.ini` with your iDRAC servers:

```ini
[General]
StompHost=activemq
StompPort=61613

[Services]
# One type per server (comma-separated)
Types=iDRAC,iDRAC,iDRAC

# One IP per server (comma-separated)
IPs=192.168.1.100,192.168.1.101,192.168.1.102

# Credentials for each server
[192.168.1.100]
username=admin
password=yourpassword123

[192.168.1.101]
username=admin
password=yourpassword456

[192.168.1.102]
username=admin
password=yourpassword789
```

---

## Directory Structure After Deployment

```
project-root/
├── config-files/                    # Configuration (create this)
│   ├── config.ini                   # Your iDRAC servers
│   └── .certs/                      # SSL certs (if needed)
│
├── docker-compose-files/
│   ├── docker-compose.yml           # Docker Compose config
│   ├── save-docker-images.sh        # ← Save images
│   ├── load-docker-images.sh        # ← Load images
│   ├── run-all.sh                   # ← Run everything
│   ├── run-offline.sh               # ← Run with options
│   ├── deploy-offline.sh            # ← Master script
│   ├── config.ini.template          # ← Config template
│   ├── OFFLINE-DEPLOYMENT.md        # ← Full guide
│   │
│   └── data/                        # Persistent data (auto-created)
│       ├── mysqldb/                 # MySQL data
│       └── victoria-metrics/        # Metrics data
│
└── docker-images-backup/            # Saved images (on external disk)
    ├── mysql-latest.tar.gz
    ├── rmohr-activemq-latest.tar.gz
    ├── victoriametrics-victoria-metrics-v1.121.0.tar.gz
    ├── idrac-telemetry-reference-tools-redfishread-latest.tar.gz
    ├── idrac-telemetry-reference-tools-configui-latest.tar.gz
    ├── idrac-telemetry-reference-tools-victoriapump-latest.tar.gz
    └── idrac-telemetry-reference-tools-dbdiscauth-latest.tar.gz
```

---

## What Gets Mounted as Volumes

The `run-all.sh` and `run-offline.sh` scripts automatically mount:

| Host Path | Container Path | Purpose |
|-----------|-----------------|---------|
| `config-files/config.ini` | `/etc/telemetry/config.ini` | iDRAC server config |
| `config-files/.certs` | `/extrabin/certs` | SSL certificates |
| `data/mysqldb` | `/var/lib/mysql` | MySQL data persistence |
| `data/victoria-metrics` | `/victoria-metrics-data` | Metrics data persistence |

---

## Key Features

✓ **Complete Image Backup** - All 7 images captured in compressed format
✓ **Easy Transfer** - .tar.gz files via USB, network, or courier
✓ **Automatic Config** - Creates config.ini template if missing
✓ **Volume Management** - Automatic handling of data persistence
✓ **Master Script** - Single entry point for deployment
✓ **Color Output** - Easy-to-follow progress with colors
✓ **Comprehensive Docs** - Full troubleshooting guide included

---

## Commands Reference

**Deployment:**
```bash
./deploy-offline.sh full                    # Guided full deployment
./deploy-offline.sh save ./backup            # Save images
./deploy-offline.sh load ./backup            # Load images
./deploy-offline.sh configure                # Setup config
./deploy-offline.sh start                    # Start services
```

**Operations:**
```bash
./run-all.sh                                 # Start all services
./run-offline.sh --victoria-db --prometheus-pump  # Custom start

docker-compose -f docker-compose-files/docker-compose.yml ps        # Status
docker-compose -f docker-compose-files/docker-compose.yml logs -f   # Logs
docker-compose -f docker-compose-files/docker-compose.yml down      # Stop
```

**View Services:**
```
ConfigUI:        http://localhost:8812
ActiveMQ:        http://localhost:8161
Victoria Metrics: http://localhost:8428
```

---

## Next Steps

1. **Online Server**: Run `./docker-compose-files/save-docker-images.sh ./backup`
2. **Transfer**: Copy `backup/` directory to offline server
3. **Offline Server**: 
   - Load images: `./docker-compose-files/load-docker-images.sh ./backup`
   - Configure: Edit `config-files/config.ini`
   - Start: `./docker-compose-files/run-all.sh`
4. **Access Web UI**: Open http://localhost:8812

---

## Support Files

- **OFFLINE-DEPLOYMENT.md** - Complete guide with troubleshooting
- **config.ini.template** - Configuration file template
- **QUICK-START.sh** - Print quick reference guide

Run `./QUICK-START.sh` anytime to see quick reference!

