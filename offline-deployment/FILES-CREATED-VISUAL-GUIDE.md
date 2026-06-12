# 📦 OFFLINE DEPLOYMENT - FILES CREATED

## 📂 Complete File Structure

```
iDRAC-Telemetry-Reference-Tools-main/
│
├── 📄 DEPLOYMENT-SCRIPTS-CREATED.txt        ← START HERE! Full reference
├── 📄 OFFLINE-DEPLOYMENT-SUMMARY.md         ← Overview & quick start
├── 📄 OFFLINE-DEPLOYMENT-CHECKLIST.md       ← Step-by-step checklist
├── 🔧 QUICK-START.sh                        ← Quick reference guide
│
├── docker-compose-files/
│   ├── 📄 OFFLINE-DEPLOYMENT.md             ← Comprehensive guide
│   ├── 📄 config.ini.template               ← Config file template
│   │
│   ├── 🔧 save-docker-images.sh             ← Save all 7 images
│   ├── 🔧 load-docker-images.sh             ← Load images from disk
│   ├── 🔧 run-all.sh                        ← Start complete stack
│   ├── 🔧 run-offline.sh                    ← Start with options
│   ├── 🔧 deploy-offline.sh                 ← Master orchestration
│   │
│   ├── docker-compose.yml                   (existing - unchanged)
│   ├── compose.sh                           (existing - unchanged)
│   └── Dockerfile*                          (existing - unchanged)
│
├── config-files/                            ← CREATE THIS DIRECTORY
│   ├── config.ini                           ← Your iDRAC servers
│   └── .certs/                              ← SSL certs (optional)
│
└── (other existing directories...)
```

## 🎯 Quick Start (3 Steps)

### Step 1️⃣: Online Server - Save Images
```bash
cd docker-compose-files
./save-docker-images.sh ./docker-images-backup
# Creates 7 .tar.gz files (~1.5-2GB)
# Transfer to offline server ➜
```

### Step 2️⃣: Offline Server - Load Images & Configure
```bash
# Load images
./docker-compose-files/load-docker-images.sh /path/to/docker-images-backup

# Create config directory
mkdir -p config-files

# Copy and edit config
cp docker-compose-files/config.ini.template config-files/config.ini
nano config-files/config.ini  # Add your iDRAC servers
```

### Step 3️⃣: Offline Server - Run Everything
```bash
./docker-compose-files/run-all.sh
# All services start automatically ✓
# Web UI: http://localhost:8812
```

## 📋 What Each File Does

| File | Location | Purpose | Run On |
|------|----------|---------|--------|
| **save-docker-images.sh** | docker-compose-files/ | Save 7 images to disk | Online server |
| **load-docker-images.sh** | docker-compose-files/ | Load images from disk | Offline server |
| **run-all.sh** | docker-compose-files/ | Start all services | Offline server |
| **run-offline.sh** | docker-compose-files/ | Start with custom options | Offline server |
| **deploy-offline.sh** | docker-compose-files/ | Master orchestration script | Either server |
| **config.ini.template** | docker-compose-files/ | Config file template | Reference |
| **OFFLINE-DEPLOYMENT.md** | docker-compose-files/ | Detailed guide | Reference |
| **OFFLINE-DEPLOYMENT-SUMMARY.md** | Project root | Overview & workflow | Reference |
| **OFFLINE-DEPLOYMENT-CHECKLIST.md** | Project root | Step-by-step checklist | Reference |
| **DEPLOYMENT-SCRIPTS-CREATED.txt** | Project root | This file - complete reference | Reference |
| **QUICK-START.sh** | Project root | Print quick reference | Reference |

## 🚀 Usage Examples

### Interactive Guided Deployment
```bash
./docker-compose-files/deploy-offline.sh full
```
Walks you through entire process with prompts.

### Save Images on Online Server
```bash
./docker-compose-files/save-docker-images.sh /path/to/backup
```
Outputs 7 .tar.gz files ready for transfer.

### Load Images on Offline Server
```bash
./docker-compose-files/load-docker-images.sh /path/to/backup
```
Loads all images from tar files.

### Start Everything at Once
```bash
./docker-compose-files/run-all.sh
```
Starts all services with Victoria Metrics.

### Start with Custom Services
```bash
./docker-compose-files/run-offline.sh \
  --victoria-db \
  --prometheus-pump \
  --grafana
```

### Check Status
```bash
docker-compose -f docker-compose-files/docker-compose.yml ps
```

### View Logs
```bash
docker-compose -f docker-compose-files/docker-compose.yml logs -f redfishread
```

## 📊 Images Saved (7 Total)

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
Total size: ~1.5-2GB

## 🔧 Configuration Format

Place in `config-files/config.ini`:

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

## 🌐 Web Interfaces

Once services running:

| Interface | URL | Port |
|-----------|-----|------|
| ConfigUI | http://localhost:8812 | 8812 |
| ActiveMQ | http://localhost:8161 | 8161 |
| Victoria Metrics | http://localhost:8428 | 8428 |

## 📖 Documentation Files

**For Overview:**
→ `OFFLINE-DEPLOYMENT-SUMMARY.md`

**For Step-by-Step:**
→ `OFFLINE-DEPLOYMENT-CHECKLIST.md`

**For Details:**
→ `docker-compose-files/OFFLINE-DEPLOYMENT.md`

**For Quick Reference:**
→ Run `./QUICK-START.sh`

**For All Details:**
→ `DEPLOYMENT-SCRIPTS-CREATED.txt`

## ✅ What's Included

- ✅ Save Docker images to disk (offline transport)
- ✅ Load Docker images from disk
- ✅ Automatic configuration file creation
- ✅ Volume mounting for config & data persistence
- ✅ Master orchestration script
- ✅ Complete documentation
- ✅ Step-by-step checklists
- ✅ Troubleshooting guides
- ✅ Performance notes
- ✅ Backup/restore procedures
- ✅ Color-coded output
- ✅ Error checking & validation

## 🎓 Learning Path

1. Read: `DEPLOYMENT-SCRIPTS-CREATED.txt` (what was created)
2. Read: `OFFLINE-DEPLOYMENT-SUMMARY.md` (overview)
3. Follow: `OFFLINE-DEPLOYMENT-CHECKLIST.md` (step-by-step)
4. Reference: `docker-compose-files/OFFLINE-DEPLOYMENT.md` (details)
5. Run: `./docker-compose-files/deploy-offline.sh full` (execute)

## 🔍 Quick File Lookup

**"How do I save images?"**
→ Use `save-docker-images.sh`

**"How do I load images?"**
→ Use `load-docker-images.sh`

**"How do I start services?"**
→ Use `run-all.sh`

**"How do I customize what runs?"**
→ Use `run-offline.sh` with options

**"How do I do everything step-by-step?"**
→ Use `deploy-offline.sh full`

**"Where do I put my iDRAC server list?"**
→ In `config-files/config.ini`

**"I need help!"**
→ Read `OFFLINE-DEPLOYMENT-CHECKLIST.md`

**"I need detailed info"**
→ Read `docker-compose-files/OFFLINE-DEPLOYMENT.md`

## 💾 Data & Configuration

- Config directory: `config-files/`
- Config file: `config-files/config.ini`
- SSL certs: `config-files/.certs/`
- Data directory: `docker-compose-files/data/`
- MySQL data: `docker-compose-files/data/mysqldb/`
- Metrics data: `docker-compose-files/data/victoria-metrics/`

## 🚀 Next Steps

1. **Online Server**: Run `./docker-compose-files/save-docker-images.sh ./backup`
2. **Transfer**: Copy `backup/` directory to offline server
3. **Offline Server**: Run `./docker-compose-files/load-docker-images.sh ./backup`
4. **Configure**: Edit `config-files/config.ini` with your iDRAC servers
5. **Start**: Run `./docker-compose-files/run-all.sh`
6. **Verify**: Open http://localhost:8812 in browser

## 📞 Support

All scripts include help output:
```bash
./docker-compose-files/deploy-offline.sh help
./docker-compose-files/run-offline.sh --help
./QUICK-START.sh
```

Or read: `OFFLINE-DEPLOYMENT-CHECKLIST.md` → Troubleshooting section

---

**Created**: June 7, 2026  
**For**: Offline iDRAC Telemetry Deployment  
**Status**: ✅ Ready to use

