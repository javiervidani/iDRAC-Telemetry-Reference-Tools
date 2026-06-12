# Offline Deployment Scripts & Documentation

All offline deployment scripts and documentation for iDRAC Telemetry Reference Tools are located in this directory.

## 📁 Files Overview

### 🚀 Executable Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| **save-docker-images.sh** | Save all Docker images to .tar.gz files | `./save-docker-images.sh ./output-dir` |
| **load-docker-images.sh** | Load Docker images from .tar.gz files | `./load-docker-images.sh /path/to/backup` |
| **run-all.sh** | Start all services with Victoria Metrics | `./run-all.sh` |
| **run-offline.sh** | Start services with custom profiles | `./run-offline.sh --victoria-db --prometheus-pump` |
| **deploy-offline.sh** | Master orchestration script | `./deploy-offline.sh full` |
| **REFERENCE-CARD.sh** | Print quick reference guide | `./REFERENCE-CARD.sh` |
| **QUICK-START.sh** | Print quick start guide | `./QUICK-START.sh` |

### 📚 Documentation Files

| Document | Purpose |
|----------|---------|
| **README.md** | This file - directory overview |
| **OFFLINE-DEPLOYMENT.md** | Comprehensive deployment guide with troubleshooting |
| **OFFLINE-DEPLOYMENT-SUMMARY.md** | Overview and quick start workflow |
| **OFFLINE-DEPLOYMENT-CHECKLIST.md** | Step-by-step checklist for deployment |
| **FILES-CREATED-VISUAL-GUIDE.md** | Visual guide of all files and directory structure |
| **DEPLOYMENT-SCRIPTS-CREATED.txt** | Complete reference of all scripts and files |

### 🔧 Configuration Files

| File | Purpose |
|------|---------|
| **config.ini.template** | Template for iDRAC server configuration |

## 🚀 Quick Start

### Step 1: Save Images (Online Server)
```bash
./save-docker-images.sh ./docker-images-backup
# Creates 7 .tar.gz files (~1.5-2GB)
```

### Step 2: Load Images (Offline Server)
```bash
./load-docker-images.sh /path/to/docker-images-backup
```

### Step 3: Configure
```bash
# Copy and edit config template
cp config.ini.template ../../config-files/config.ini
nano ../../config-files/config.ini
```

### Step 4: Run
```bash
./run-all.sh
# All services start automatically
```

## 📖 Which Document Should I Read?

- **Just starting?** → `OFFLINE-DEPLOYMENT-SUMMARY.md`
- **Step-by-step guide?** → `OFFLINE-DEPLOYMENT-CHECKLIST.md`
- **Need details?** → `OFFLINE-DEPLOYMENT.md`
- **Quick reference?** → Run `./REFERENCE-CARD.sh`
- **Visual guide?** → `FILES-CREATED-VISUAL-GUIDE.md`
- **Complete reference?** → `DEPLOYMENT-SCRIPTS-CREATED.txt`

## 🎯 Common Tasks

### Save Docker Images
```bash
./save-docker-images.sh ./my-backup
```

### Load Docker Images
```bash
./load-docker-images.sh ./my-backup
```

### Start All Services
```bash
./run-all.sh
```

### Start Custom Services
```bash
./run-offline.sh --victoria-db --prometheus-pump --grafana
```

### Interactive Guided Deployment
```bash
./deploy-offline.sh full
```

### Check Service Status
```bash
docker-compose -f ../../docker-compose.yml ps
```

### View Logs
```bash
docker-compose -f ../../docker-compose.yml logs -f
```

### Print Quick Reference
```bash
./REFERENCE-CARD.sh
```

## 🌐 Web Interfaces

Once services are running:

| Service | URL |
|---------|-----|
| ConfigUI | http://localhost:8812 |
| ActiveMQ | http://localhost:8161 |
| Victoria Metrics | http://localhost:8428 |

## 📝 Configuration File

Create `../../config-files/config.ini` with your iDRAC servers:

```ini
[General]
StompHost=activemq
StompPort=61613

[Services]
Types=iDRAC,iDRAC,iDRAC
IPs=192.168.1.100,192.168.1.101,192.168.1.102

[192.168.1.100]
username=admin
password=password123

[192.168.1.101]
username=admin
password=password456

[192.168.1.102]
username=admin
password=password789
```

## 📂 Directory Structure

```
project-root/
├── config-files/              ← Your iDRAC configuration
│   ├── config.ini             
│   └── .certs/
├── docker-compose-files/
│   ├── offline-deployment/    ← YOU ARE HERE
│   │   ├── save-docker-images.sh
│   │   ├── load-docker-images.sh
│   │   ├── run-all.sh
│   │   ├── run-offline.sh
│   │   ├── deploy-offline.sh
│   │   ├── config.ini.template
│   │   ├── *.md (documentation)
│   │   └── README.md (this file)
│   ├── docker-compose.yml
│   └── data/                  ← Persistent data
└── ...
```

## 🔗 Important Paths

When running scripts from this directory:
- Config: `../../config-files/config.ini`
- Data: `../data/`
- Docker Compose: `../docker-compose.yml`

Scripts automatically handle these paths.

## ⚠️ Important Notes

1. **Save on online server first** - Use `save-docker-images.sh`
2. **Transfer images** - Copy `docker-images-backup/` to offline server
3. **Load images** - Use `load-docker-images.sh`
4. **Configure** - Edit `config.ini` with your iDRAC servers
5. **Run** - Use `run-all.sh` to start everything

## 🆘 Need Help?

### Quick Help
- Scripts have `--help` option: `./run-offline.sh --help`
- Print reference card: `./REFERENCE-CARD.sh`

### Detailed Help
- Read: `OFFLINE-DEPLOYMENT-CHECKLIST.md`
- Or: `OFFLINE-DEPLOYMENT.md`

### Troubleshooting
See `OFFLINE-DEPLOYMENT-CHECKLIST.md` → Troubleshooting section

## 📊 Docker Images (7 Total)

**External (pre-built):**
- mysql:latest
- rmohr/activemq:latest
- victoriametrics/victoria-metrics:v1.121.0

**Custom (built):**
- idrac-telemetry-reference-tools/redfishread
- idrac-telemetry-reference-tools/configui
- idrac-telemetry-reference-tools/victoriapump
- idrac-telemetry-reference-tools/dbdiscauth

**Total size:** ~1.5-2GB (compressed)

## ✅ Checklist

- [ ] Read the relevant documentation
- [ ] Save images on online server
- [ ] Transfer images to offline server
- [ ] Load images
- [ ] Configure `config.ini`
- [ ] Run services
- [ ] Access web UI
- [ ] Verify data collection

## 📖 Documentation Map

```
README.md (this file)
├── OFFLINE-DEPLOYMENT-SUMMARY.md    → Overview & workflow
├── OFFLINE-DEPLOYMENT-CHECKLIST.md  → Step-by-step
├── OFFLINE-DEPLOYMENT.md            → Comprehensive guide
├── FILES-CREATED-VISUAL-GUIDE.md    → Visual reference
└── DEPLOYMENT-SCRIPTS-CREATED.txt   → Complete reference
```

---

**Last Updated:** June 7, 2026  
**Status:** ✅ Ready to use

