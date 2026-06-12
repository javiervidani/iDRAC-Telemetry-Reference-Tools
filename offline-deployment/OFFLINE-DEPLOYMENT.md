# Offline Docker Deployment Guide

This guide explains how to save all Docker images from your online server and run them on an offline server.

## Overview

The iDRAC Telemetry Reference Tools require several Docker images:
- **Built Images**: `idrac-telemetry-reference-tools/redfishread`, `configui`, `victoriapump`, `dbdiscauth`
- **External Images**: `mysql:latest`, `rmohr/activemq:latest`, `victoriametrics/victoria-metrics:v1.121.0`

## Step 1: Save Docker Images on Online Server

### On your online/development server:

```bash
cd docker-compose-files

# Save all images to a directory
./save-docker-images.sh ./docker-images-backup

# This will create .tar.gz files for each image
# Total size will be 500MB-1GB depending on image sizes
```

**Output files created:**
```
docker-images-backup/
├── mysql-latest.tar.gz
├── rmohr-activemq-latest.tar.gz
├── victoriametrics-victoria-metrics-v1.121.0.tar.gz
├── idrac-telemetry-reference-tools-redfishread-latest.tar.gz
├── idrac-telemetry-reference-tools-configui-latest.tar.gz
├── idrac-telemetry-reference-tools-victoriapump-latest.tar.gz
└── idrac-telemetry-reference-tools-dbdiscauth-latest.tar.gz
```

### Transfer to Offline Server

Copy the `docker-images-backup` directory to your offline server via:
- USB drive
- Secure file transfer (SCP, SFTP)
- Network air-gap transfer protocol

## Step 2: Load Docker Images on Offline Server

### On your offline server:

```bash
cd docker-compose-files

# Load all images from the backup
./load-docker-images.sh /path/to/docker-images-backup

# Verify images were loaded
docker images | grep -E "idrac-telemetry|mysql|activemq|victoria-metrics"
```

## Step 3: Create Configuration File

### Create the config directory:

```bash
mkdir -p config-files
```

### Create `config-files/config.ini`:

The configuration file defines your iDRAC servers. Example:

```ini
[General]
StompHost=activemq
StompPort=61613

[Services]
; List of iDRAC server types (one per server)
Types=iDRAC,iDRAC,iDRAC

; List of iDRAC server IPs (must match Types count)
IPs=192.168.1.100,192.168.1.101,192.168.1.102

; Credentials for each iDRAC server
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

## Step 4: Run Services

### Option A: Run All Services (Victoria Metrics + All Pumps)

```bash
./run-all.sh
```

This starts:
- ✓ Core services (ActiveMQ, MySQL, ConfigUI, Redfish reader)
- ✓ Victoria Metrics database
- ✓ Victoria Metrics pump
- ✓ Data collection from configured iDRAC servers

### Option B: Run Custom Configuration

```bash
./run-offline.sh --victoria-db --victoria-pump --prometheus-pump --grafana
```

Available options:
- `--victoria-db` - Victoria Metrics database
- `--victoria-pump` - Victoria Metrics data pump
- `--prometheus-pump` - Prometheus data pump
- `--influx-pump` - InfluxDB pump
- `--splunk-pump` - Splunk pump
- `--grafana` - Grafana dashboards

## Directory Structure

After setup, your offline server should have:

```
iDRAC-Telemetry-Reference-Tools-main/
├── config-files/              # Configuration
│   ├── config.ini             # iDRAC servers configuration
│   └── .certs/                # SSL certificates (if needed)
├── docker-compose-files/
│   ├── docker-compose.yml
│   ├── run-all.sh             # Run all services
│   ├── run-offline.sh         # Run with custom config
│   ├── save-docker-images.sh  # (not needed on offline server)
│   ├── load-docker-images.sh  # Load images from backup
│   └── data/                  # Persistent data (auto-created)
│       ├── mysqldb/           # MySQL data
│       └── victoria-metrics/  # Victoria Metrics data
└── ...
```

## Web Interfaces

Once services are running:

| Service | URL |
|---------|-----|
| ConfigUI | http://localhost:8812 |
| ActiveMQ | http://localhost:8161 |
| Victoria Metrics | http://localhost:8428 |
| Grafana (if enabled) | http://localhost:3000 |

## Useful Commands

### View running services:
```bash
docker-compose -f docker-compose-files/docker-compose.yml ps
```

### View logs:
```bash
docker-compose -f docker-compose-files/docker-compose.yml logs -f

# Follow logs for specific service:
docker-compose -f docker-compose-files/docker-compose.yml logs -f redfishread
```

### Stop services:
```bash
docker-compose -f docker-compose-files/docker-compose.yml down
```

### Restart a service:
```bash
docker-compose -f docker-compose-files/docker-compose.yml restart redfishread
```

### Check disk usage:
```bash
# View data directory size
du -sh docker-compose-files/data/

# View individual volumes
docker volume ls
docker volume inspect <volume-name>
```

## Troubleshooting

### Issue: Config file not being picked up

**Solution**: Place `config.ini` in the `config-files/` directory and restart services:
```bash
docker-compose -f docker-compose-files/docker-compose.yml restart redfishread dbdiscauth
```

### Issue: Services won't start

**Check logs**:
```bash
docker-compose -f docker-compose-files/docker-compose.yml logs activemq
docker-compose -f docker-compose-files/docker-compose.yml logs mysqldb
```

### Issue: Can't connect to iDRAC servers

1. Verify network connectivity: `ping 192.168.1.100`
2. Check credentials in `config.ini`
3. Verify iDRAC servers are using correct ports (usually Redfish on 443)
4. Check container logs: `docker-compose -f docker-compose-files/docker-compose.yml logs redfishread`

### Issue: Low disk space

Victoria Metrics stores time-series data. Monitor disk usage:
```bash
# Check metrics volume size
du -sh docker-compose-files/data/victoria-metrics/

# Adjust retention in docker-compose.yml if needed
```

## Performance Notes

- **MySQL**: Requires ~2GB for initial setup
- **Victoria Metrics**: Grows ~500MB-1GB per week depending on server count
- **Total memory**: ~2GB minimum recommended
- **CPU**: 2+ cores recommended for 10+ iDRAC servers

## Backup & Restore

### Backup configuration and data:
```bash
# Backup everything
tar -czf idrac-telemetry-backup.tar.gz \
    config-files/ \
    docker-compose-files/data/

# Restore from backup
tar -xzf idrac-telemetry-backup.tar.gz
```

## Support

For issues or questions:
- Check logs: `docker-compose logs -f`
- Review config.ini format
- Ensure iDRAC servers are accessible from container network
- Verify Docker and Docker Compose versions are up to date

