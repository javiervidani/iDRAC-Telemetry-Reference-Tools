#!/bin/bash
# REFERENCE CARD - Print this or keep open while deploying
# Run: ./docker-compose-files/deploy-offline.sh full

cat << 'EOF'

╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║          IDRAC TELEMETRY - OFFLINE DEPLOYMENT REFERENCE CARD            ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 1: ONLINE SERVER - SAVE IMAGES                                    │
└─────────────────────────────────────────────────────────────────────────┘

Command:
  cd docker-compose-files
  ./save-docker-images.sh ./docker-images-backup

Output:
  ✓ 7 .tar.gz files created (~1.5-2GB total)
  ✓ Ready to transfer to offline server

Transfer:
  → USB drive  → Network transfer  → Courier  → etc.

┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 2: OFFLINE SERVER - LOAD IMAGES                                   │
└─────────────────────────────────────────────────────────────────────────┘

Command:
  ./docker-compose-files/load-docker-images.sh /path/to/docker-images-backup

Verify:
  docker images | grep -E "idrac-telemetry|mysql|activemq|victoria"

Expected:
  ✓ 7 images loaded
  ✓ All tags match

┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 3: CREATE CONFIGURATION                                            │
└─────────────────────────────────────────────────────────────────────────┘

Create Directory:
  mkdir -p config-files

Create/Edit Config:
  cp docker-compose-files/config.ini.template config-files/config.ini
  nano config-files/config.ini

Config Format:
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

  ... (repeat for each server)

Checklist:
  ☐ All iDRAC servers listed in IPs=
  ☐ Types count matches IPs count
  ☐ Credentials added for each server
  ☐ File saved as config-files/config.ini

┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 4: START SERVICES                                                  │
└─────────────────────────────────────────────────────────────────────────┘

Simple (All Services):
  ./docker-compose-files/run-all.sh

Custom (Select Services):
  ./docker-compose-files/run-offline.sh --victoria-db --prometheus-pump

Expected Output:
  ✓ activemq: Up
  ✓ mysqldb: Up
  ✓ configui: Up
  ✓ redfishread: Up
  ✓ dbdiscauth: Up
  ✓ victoriapump: Up
  ✓ victoriametrics: Up

┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 5: VERIFY & ACCESS                                                │
└─────────────────────────────────────────────────────────────────────────┘

Check Status:
  docker-compose -f docker-compose-files/docker-compose.yml ps

View Logs:
  docker-compose -f docker-compose-files/docker-compose.yml logs -f

Web Interfaces:
  ConfigUI:         http://localhost:8812
  ActiveMQ:         http://localhost:8161
  Victoria Metrics: http://localhost:8428

Data Directory:
  docker-compose-files/data/

Configuration:
  config-files/config.ini

┌─────────────────────────────────────────────────────────────────────────┐
│ QUICK COMMANDS                                                          │
└─────────────────────────────────────────────────────────────────────────┘

View service status:
  docker-compose -f docker-compose-files/docker-compose.yml ps

View all logs:
  docker-compose -f docker-compose-files/docker-compose.yml logs -f

View specific service:
  docker-compose -f docker-compose-files/docker-compose.yml logs -f redfishread

Stop all services:
  docker-compose -f docker-compose-files/docker-compose.yml down

Restart service:
  docker-compose -f docker-compose-files/docker-compose.yml restart redfishread

Check disk usage:
  du -sh docker-compose-files/data/*

Run with custom services:
  ./docker-compose-files/run-offline.sh --victoria-db --prometheus-pump --grafana

See available options:
  ./docker-compose-files/run-offline.sh --help

Use interactive wizard:
  ./docker-compose-files/deploy-offline.sh full

┌─────────────────────────────────────────────────────────────────────────┐
│ TROUBLESHOOTING QUICK FIXES                                             │
└─────────────────────────────────────────────────────────────────────────┘

Services won't start?
  → Check logs: docker-compose logs
  → Check disk space: df -h
  → Check ports: netstat -an | grep LISTEN

Can't reach iDRAC servers?
  → Ping servers: ping 192.168.1.100
  → Check firewall rules
  → Verify credentials in config.ini
  → Check iDRAC servers are powered on

Config file not picked up?
  → Check file location: ls config-files/config.ini
  → Restart service: docker-compose restart redfishread
  → Check file permissions: ls -la config-files/

No data being collected?
  → Check redfishread logs: docker-compose logs redfishread
  → Verify iDRAC servers are accessible
  → Check MySQL is running: docker-compose logs mysqldb
  → Check disk space: df -h

┌─────────────────────────────────────────────────────────────────────────┐
│ DOCUMENTATION                                                            │
└─────────────────────────────────────────────────────────────────────────┘

Quick start:        ./QUICK-START.sh
Summary:            OFFLINE-DEPLOYMENT-SUMMARY.md
Checklist:          OFFLINE-DEPLOYMENT-CHECKLIST.md
Full guide:         docker-compose-files/OFFLINE-DEPLOYMENT.md
All files:          DEPLOYMENT-SCRIPTS-CREATED.txt
Visual guide:       FILES-CREATED-VISUAL-GUIDE.md

┌─────────────────────────────────────────────────────────────────────────┐
│ DOCKER IMAGES (7 TOTAL)                                                │
└─────────────────────────────────────────────────────────────────────────┘

External (pre-built):
  • mysql:latest
  • rmohr/activemq:latest
  • victoriametrics/victoria-metrics:v1.121.0

Custom (built):
  • idrac-telemetry-reference-tools/redfishread
  • idrac-telemetry-reference-tools/configui
  • idrac-telemetry-reference-tools/victoriapump
  • idrac-telemetry-reference-tools/dbdiscauth

Total size: ~1.5-2GB (compressed)

┌─────────────────────────────────────────────────────────────────────────┐
│ VOLUMES & PERSISTENCE                                                   │
└─────────────────────────────────────────────────────────────────────────┘

Volume Mounts (automatic):
  config-files/config.ini  → /etc/telemetry/config.ini
  config-files/.certs      → /extrabin/certs
  data/mysqldb             → /var/lib/mysql
  data/victoria-metrics    → /victoria-metrics-data

Data Persists:
  ✓ Across container restarts
  ✓ In data/ directory
  ✓ Backed up with: tar -czf backup.tar.gz config-files/ data/

┌─────────────────────────────────────────────────────────────────────────┐
│ REMEMBER                                                                 │
└─────────────────────────────────────────────────────────────────────────┘

1. Save images on ONLINE server first
2. Transfer docker-images-backup/ to OFFLINE server
3. Load images on OFFLINE server
4. Configure config.ini with your iDRAC servers
5. Run run-all.sh to start everything
6. Access Web UI at http://localhost:8812
7. Check logs if anything goes wrong
8. Data persists in docker-compose-files/data/

╔═══════════════════════════════════════════════════════════════════════════╗
║  For more help, see: OFFLINE-DEPLOYMENT-CHECKLIST.md                      ║
║  Or run: ./docker-compose-files/deploy-offline.sh full                    ║
╚═══════════════════════════════════════════════════════════════════════════╝

EOF
