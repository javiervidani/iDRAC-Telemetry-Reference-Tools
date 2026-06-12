# iDRAC Telemetry Stack - Offline Deployment Summary

## Server
- **Host:** `10.0.0.150` (RHEL9, offline)
- **Project path:** `/home/gpadmin/idrac/`

## Web Interfaces

| Service | URL | Credentials |
|---|---|---|
| ConfigUI | http://10.0.0.150:8080 | — |
| Grafana | http://10.0.0.150:3000 | admin / admin123 |
| VictoriaMetrics | http://10.0.0.150:8428/vmui | — |
| ActiveMQ | http://10.0.0.150:8161 | admin / admin |

## Stack Architecture

```
iDRAC Servers
     │  (Redfish API)
     ▼
redfishread  ──►  ActiveMQ  ──►  victoriapump  ──►  VictoriaMetrics
                                                           │
dbdiscauth ──► MySQL (server configs)                      ▼
                                                        Grafana
ConfigUI   ──► MySQL (server configs)
```

## How It Works

1. **ConfigUI** — add iDRAC server IPs + credentials, saved in MySQL
2. **dbdiscauth** — reads server list from MySQL, handles Redfish authentication
3. **redfishread** — connects to each iDRAC via Redfish API, streams telemetry to ActiveMQ
4. **victoriapump** — consumes messages from ActiveMQ, writes metrics to VictoriaMetrics
5. **Grafana** — queries VictoriaMetrics and displays dashboards

## Persistent Data (Docker Volumes)

```bash
docker volume inspect idrac-victoria-metrics-data   # telemetry metrics
docker volume inspect idrac-mysqldb-volume           # iDRAC server configs
```

Located under `/var/lib/docker/volumes/`

## MySQL

- **Database:** `telemetrysource_services_db`
- **User:** `reftools`
- **Tables:** `services`, `HttpEventCollector`
- **Password:** stored in `/home/gpadmin/idrac/.env`

```bash
# Check saved iDRAC servers
docker exec -it mysqldb mysql -u reftools -p<password> telemetrysource_services_db -e "SELECT * FROM services;"
```

## Start / Stop

```bash
# Start
bash /home/gpadmin/idrac/offline-deployment/run-all.sh

# Stop
docker compose -f /home/gpadmin/idrac/docker-compose.yml down

# Stop and wipe all data
docker compose -f /home/gpadmin/idrac/docker-compose.yml down -v
```

## Deployment Files

```
/home/gpadmin/idrac/
├── docker-compose.yml
├── .env                          # generated secrets
├── .certs/
├── grafana-provisioning/
│   └── datasources/
│       └── victoriametrics.yaml  # auto-provisioned datasource
└── offline-deployment/
    ├── run-all.sh
    ├── load-docker-images.sh
    └── output-dir/
        ├── grafana-9.0.1.tar.gz
        ├── idrac-telemetry-reference-tools-configui-latest.tar.gz
        ├── idrac-telemetry-reference-tools-dbdiscauth-latest.tar.gz
        ├── idrac-telemetry-reference-tools-redfishread-latest.tar.gz
        ├── idrac-telemetry-reference-tools-victoriapump-latest.tar.gz
        ├── mysql-latest.tar.gz
        ├── rmohr-activemq-latest.tar.gz
        └── victoriametrics-victoria-metrics-v1.121.0.tar.gz
```
