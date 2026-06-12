# Offline Deployment Checklist

## Step 1: Save Images on Online Server ✓

### Prerequisites:
- [ ] Docker is installed and running
- [ ] Docker Compose is installed (v2.2.0+)
- [ ] All Docker images are built or pulled
- [ ] At least 2GB free disk space

### Execution:
```bash
cd docker-compose-files
./save-docker-images.sh ./docker-images-backup
```

### Expected Output:
- [ ] 7 .tar.gz files created (one per image)
- [ ] Total size ~1.5-2GB
- [ ] All files have content (not empty)

### Files to Transfer:
- [ ] Entire `docker-images-backup/` directory
- [ ] Method: USB drive / Secure transfer / Network
- [ ] Verify files arrived intact (check file sizes)

---

## Step 2: Load Images on Offline Server ✓

### Prerequisites:
- [ ] Docker is installed on offline server
- [ ] Docker service is running
- [ ] `docker-images-backup/` copied to offline server
- [ ] At least 3GB free disk space

### Execution:
```bash
cd docker-compose-files
./load-docker-images.sh /path/to/docker-images-backup
```

### Verification:
```bash
docker images | grep -E "idrac-telemetry|mysql|activemq|victoria"
```

### Expected Output:
- [ ] 7 images loaded successfully
- [ ] All images show with proper tags
- [ ] No "image not found" errors

---

## Step 3: Configure iDRAC Servers ✓

### Create Config Directory:
```bash
mkdir -p config-files
```

### Create Configuration File:
```bash
# Option A: Copy template
cp docker-compose-files/config.ini.template config-files/config.ini

# Option B: Create manually
nano config-files/config.ini
```

### Edit Configuration:
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

### Checklist:
- [ ] All iDRAC server IPs listed under `IPs=`
- [ ] Types count matches IPs count
- [ ] Credentials configured for each IP
- [ ] File saved as `config-files/config.ini`
- [ ] File permissions allow reading (at minimum 644)

---

## Step 4: Verify Network Connectivity ✓

Before starting services, verify iDRAC servers are reachable:

```bash
# Test each iDRAC server
ping 192.168.1.100
ping 192.168.1.101
ping 192.168.1.102

# Or use curl to test HTTPS port
curl -k https://192.168.1.100:443/redfish/v1/ 2>/dev/null | head -20
```

### Checklist:
- [ ] All iDRAC servers respond to ping
- [ ] Network routes are configured
- [ ] Firewall allows HTTPS (port 443) from container network
- [ ] iDRAC servers are powered on and responsive

---

## Step 5: Start Services ✓

### Option A: Start All Services (Recommended)
```bash
./docker-compose-files/run-all.sh
```

### Option B: Start with Custom Configuration
```bash
./docker-compose-files/run-offline.sh \
    --victoria-db \
    --victoria-pump \
    --prometheus-pump
```

### Option C: Use Master Deployment Script
```bash
./docker-compose-files/deploy-offline.sh full
```

### Expected Output:
- [ ] All containers start without errors
- [ ] No port conflicts reported
- [ ] Services marked as "Up"

---

## Step 6: Verify Services are Running ✓

```bash
# Check container status
docker-compose -f docker-compose-files/docker-compose.yml ps

# Check logs for errors
docker-compose -f docker-compose-files/docker-compose.yml logs

# View specific service logs
docker-compose -f docker-compose-files/docker-compose.yml logs redfishread
```

### Expected Status:
- [ ] activemq: Up (Port 8161)
- [ ] mysqldb: Up (Port 3306)
- [ ] configui: Up (Port 8082)
- [ ] redfishread: Up
- [ ] dbdiscauth: Up
- [ ] victoriapump-standalone: Up (Port 2112)
- [ ] victoriametrics: Up (Port 8428)

---

## Step 7: Access Web Interfaces ✓

Open in your browser:

| Service | URL | Port |
|---------|-----|------|
| ConfigUI | http://localhost:8812 | 8812 |
| ActiveMQ | http://localhost:8161 | 8161 |
| Victoria Metrics | http://localhost:8428 | 8428 |

### Checklist:
- [ ] ConfigUI loads without errors
- [ ] Can view active connections
- [ ] Can see message queue status in ActiveMQ
- [ ] Victoria Metrics dashboard is accessible

---

## Step 8: Verify Data Collection ✓

### Check iDRAC Reader Logs:
```bash
docker-compose -f docker-compose-files/docker-compose.yml logs -f redfishread
```

### Expected in Logs:
- [ ] Connection attempts to iDRAC servers
- [ ] No authentication errors
- [ ] Data collection starting messages

### Monitor Data:
```bash
# Check Victoria Metrics for data
curl http://localhost:8428/api/v1/query?query=node_cpu_info

# Check message queue
# Visit http://localhost:8161 and check Queue size
```

### Checklist:
- [ ] No obvious connection errors in logs
- [ ] Data points appearing in Victoria Metrics
- [ ] Messages flowing through ActiveMQ queue
- [ ] MySQL database growing with data

---

## Step 9: Test Data Persistence ✓

### Verify Volume Mounts:
```bash
ls -la docker-compose-files/data/
du -sh docker-compose-files/data/*
```

### Stop and Restart:
```bash
# Stop containers
docker-compose -f docker-compose-files/docker-compose.yml down

# Restart
./docker-compose-files/run-all.sh

# Verify data still present
ls -la docker-compose-files/data/
```

### Checklist:
- [ ] Data directory exists and grows over time
- [ ] MySQL data persists across restart
- [ ] Metrics data persists across restart
- [ ] No data loss on container restart

---

## Step 10: Backup Configuration ✓

### Create Backup:
```bash
# Backup configuration and data
tar -czf idrac-telemetry-backup.tar.gz \
    config-files/ \
    docker-compose-files/data/

# Verify backup
tar -tzf idrac-telemetry-backup.tar.gz | head -20
```

### Store Backup:
- [ ] Save backup to external storage
- [ ] Backup file is readable
- [ ] Keep in safe location
- [ ] Document backup location

---

## Troubleshooting Checklist

### If Services Won't Start:
- [ ] Check Docker is running: `docker ps`
- [ ] Check port conflicts: `netstat -an | grep LISTEN`
- [ ] View error logs: `docker-compose logs`
- [ ] Check disk space: `df -h`
- [ ] Check memory: `free -h`

### If Can't Connect to iDRAC:
- [ ] Ping servers: `ping 192.168.1.100`
- [ ] Check firewall rules
- [ ] Verify iDRAC servers are powered on
- [ ] Check credentials in config.ini
- [ ] Review redfishread logs: `docker-compose logs redfishread`

### If Data Not Collecting:
- [ ] Check ActiveMQ is running: `curl http://localhost:8161`
- [ ] Check MySQL is running: `docker-compose logs mysqldb`
- [ ] Check disk space: `df -h`
- [ ] Review telemetry logs: `docker-compose logs redfishread`
- [ ] Verify iDRAC credentials are correct

### If Web UI Won't Load:
- [ ] Check container is running: `docker-compose ps`
- [ ] Check logs: `docker-compose logs configui`
- [ ] Check port binding: `netstat -an | grep 8812`
- [ ] Try different browser
- [ ] Clear browser cache

---

## Performance Monitoring

### Monitor Disk Usage:
```bash
# Check data directory growth
watch -n 5 'du -sh docker-compose-files/data/*'

# Check individual volumes
docker volume ls
docker volume inspect <volume-name>
```

### Monitor Memory:
```bash
# Check container memory usage
docker stats
```

### Monitor CPU:
```bash
# Check container CPU usage
docker stats
```

---

## Post-Deployment Tasks

### Document Your Setup:
- [ ] Record iDRAC server list with passwords (in secure location)
- [ ] Document custom configuration changes
- [ ] Note any network/firewall rules applied
- [ ] Create runbook for starting/stopping services

### Schedule Backups:
- [ ] Setup automated backup script
- [ ] Test backup restore procedure
- [ ] Schedule backup job (daily/weekly)
- [ ] Monitor backup success

### Monitor Long-term:
- [ ] Watch disk growth (especially Victoria Metrics)
- [ ] Monitor container health
- [ ] Review logs for errors
- [ ] Update config as iDRAC servers change

---

## Maintenance Procedures

### Weekly:
- [ ] Check disk space: `du -sh docker-compose-files/data/*`
- [ ] Review error logs
- [ ] Verify data collection is continuous

### Monthly:
- [ ] Create full backup
- [ ] Test backup restoration
- [ ] Review and update config.ini if needed

### Quarterly:
- [ ] Check for Docker updates
- [ ] Review performance metrics
- [ ] Plan capacity expansion if needed

---

## Helpful Commands Reference

```bash
# View all services
docker-compose -f docker-compose-files/docker-compose.yml ps

# View logs for specific service
docker-compose -f docker-compose-files/docker-compose.yml logs -f redfishread

# Restart a service
docker-compose -f docker-compose-files/docker-compose.yml restart redfishread

# Stop all services
docker-compose -f docker-compose-files/docker-compose.yml down

# Remove volumes (WARNING: deletes data!)
docker-compose -f docker-compose-files/docker-compose.yml down -v

# View container resource usage
docker stats

# Check specific container logs
docker logs <container-name>

# Execute command in running container
docker exec <container-name> <command>
```

---

## Sign-off

- [ ] All steps completed successfully
- [ ] Services running and collecting data
- [ ] Web interfaces accessible
- [ ] Backup created and verified
- [ ] Documentation complete
- [ ] Ready for production use

**Deployment Date**: _______________
**Deployed By**: _______________
**Notes**: _____________________________________________________

