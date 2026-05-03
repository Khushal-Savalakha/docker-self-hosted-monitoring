# 🔭 docker-self-hosted-monitoring

> A production-ready, fully self-hosted observability platform built with Docker Compose.
> Monitor infrastructure metrics, aggregate logs, trace application performance, and analyze product analytics — all on your own infrastructure, zero vendor lock-in.

---

## 📌 Table of Contents

- [Overview](#-overview)
- [Repository Structure](#-repository-structure)
- [Stack Summary](#-stack-summary)
- [Grafana Suite](#-grafana-suite--infrastructure-monitoring)
- [Analytics Suite](#-analytics-suite--apm--product-analytics)
- [Port Reference](#-port-reference)
- [Getting Started](#-getting-started)
- [Environment Variables](#-environment-variables)
- [Makefile Commands](#-makefile-commands)
- [Dashboards](#-dashboards)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🧭 Overview

This repository provides two independent but complementary Docker Compose stacks for complete self-hosted observability:

| Suite | Purpose |
|-------|---------|
| **grafana-suite** | Infrastructure monitoring — metrics, logs, and alerting |
| **analytics-suite** | APM, distributed tracing, log management, and product analytics |

Both stacks are designed to run on a single server or be split across machines. No cloud accounts, no SaaS fees, no data leaving your infrastructure.

---

## 📁 Repository Structure

```
docker-self-hosted-monitoring/
├── .gitignore
└── observability-stack/
    ├── grafana-suite/                        # Infrastructure monitoring
    │   ├── docker-compose.yml
    │   ├── prometheus.yml                    # Scrape config (120s interval)
    │   ├── loki-config.yml                   # Log storage & retention config
    │   ├── promtail-config.yml               # Log collector config
    │   ├── restart.sh                        # Stack restart helper
    │   └── dashboards/
    │       ├── container-log-monitoring.json
    │       ├── container-resource-observability.json
    │       └── system-resource-utilization.json
    │
    └── analytics-suite/                      # APM + product analytics
        ├── docker-compose.yml
        ├── nginx.conf                        # SigNoz frontend reverse proxy
        ├── otel-collector-config.yaml        # OpenTelemetry pipeline
        ├── Makefile                          # Service management shortcuts
        ├── example.env                       # Environment variable template
        ├── clickhouse-config/
        │   ├── cluster.xml                   # SigNoz ClickHouse cluster config
        │   └── macros.xml
        └── posthog-clickhouse-config/
            ├── cluster.xml                   # PostHog ClickHouse cluster config
            └── macros.xml
```

---

## 📦 Stack Summary

### 🟦 Grafana Suite

| Service | Image | Role |
|---------|-------|------|
| Grafana | `grafana/grafana:latest` | Visualization & dashboards |
| Prometheus | `prom/prometheus:latest` | Metrics collection & storage |
| Loki | `grafana/loki:3.0.0` | Log aggregation & querying |
| Promtail | `grafana/promtail:3.0.0` | Log shipping agent |
| Node Exporter | `prom/node-exporter:latest` | Host system metrics |
| cAdvisor | `gcr.io/cadvisor/cadvisor:latest` | Container metrics |

### 🟧 Analytics Suite

| Service | Image | Role |
|---------|-------|------|
| SigNoz Frontend | `signoz/frontend:latest` | APM UI |
| SigNoz Query Service | `signoz/query-service:latest` | Backend API |
| SigNoz OTel Collector | `signoz/signoz-otel-collector:latest` | OpenTelemetry ingestion |
| SigNoz Schema Migrator | `signoz/signoz-schema-migrator:latest` | Schema lifecycle |
| ClickHouse | `clickhouse/clickhouse-server:latest` | SigNoz telemetry store |
| PostHog | `posthog/posthog:release-1.43.1` | Product analytics |
| PostHog ClickHouse | `clickhouse/clickhouse-server:21.8` | PostHog event store |
| Kafka | `confluentinc/cp-kafka:7.3.0` | PostHog event streaming |
| Zookeeper | `confluentinc/cp-zookeeper:7.3.0` | Kafka coordination |
| Redis | `redis:7` | PostHog caching & queues |
| Graylog | `graylog/graylog:5.0` | Centralized log management |
| Elasticsearch | `elasticsearch-oss:7.10.2` | Graylog search backend |
| MongoDB | `mongo:5.0` | Graylog metadata store |

---

## 📊 Grafana Suite — Infrastructure Monitoring

The Grafana suite provides complete visibility into host and container metrics alongside centralized log management.

**Features:**
- Scrapes host metrics via Node Exporter every 120 seconds
- Collects container metrics via cAdvisor
- Ships Docker and system logs via Promtail → Loki
- 3 pre-built Grafana dashboards included out of the box
- SMTP alerting support configured via environment variables
- 200-hour Prometheus TSDB retention with lifecycle API enabled
- Loki configured with TSDB schema v13, 168-hour log retention

### Start Grafana Suite

```bash
cd observability-stack/grafana-suite
docker-compose up -d
```

---

## 🔬 Analytics Suite — APM & Product Analytics

The analytics suite combines three powerful tools into a single Docker Compose stack.

### SigNoz — Application Performance Monitoring

OpenTelemetry-native APM with distributed tracing, metrics, and log correlation backed by ClickHouse.

- Ingests traces, metrics, and logs via OTLP (gRPC + HTTP)
- Batches up to 10,000 spans per flush with 10s timeout
- Schema migrations run automatically on startup via `schema-migrator`
- Query service exposes REST API on port 8082
- Frontend served via nginx reverse proxy on port 3301

### Graylog — Centralized Log Management

Enterprise-grade log aggregation with full-text search, alerting, and dashboards.

- Accepts logs via GELF UDP on port 12201
- Full-text search powered by Elasticsearch
- Web UI accessible on port 9001
- MongoDB stores stream configurations and metadata

### PostHog — Product Analytics

Self-hosted product analytics for tracking user behaviour, funnels, cohorts, and feature flags.

- Event ingestion via Kafka for high-throughput reliability
- ClickHouse (v21.8) as dedicated analytics event store
- Plugin server runs alongside the web app for pipeline processing
- Configurable via `.env` — no hardcoded secrets

### Start Analytics Suite

```bash
cd observability-stack/analytics-suite
cp example.env .env        # Fill in your secrets
docker-compose up -d
```

---

## 🌐 Port Reference

| Service | Port | URL |
|---------|------|-----|
| Grafana | `3011` | `http://localhost:3011` |
| Prometheus | `9090` | `http://localhost:9090` |
| Loki | `3100` | `http://localhost:3100` |
| Promtail | `9080` | `http://localhost:9080` |
| Node Exporter | `9100` | `http://localhost:9100` |
| cAdvisor | `8080` | `http://localhost:8080` |
| SigNoz UI | `3301` | `http://localhost:3301` |
| SigNoz Query API | `8082` | `http://localhost:8082` |
| OTLP gRPC | `4317` | — |
| OTLP HTTP | `4318` | — |
| Graylog UI | `9001` | `http://localhost:9001` |
| GELF UDP | `12201` | — |
| ClickHouse HTTP | `8123` | `http://localhost:8123` |
| ClickHouse TCP | `9002` | — |
| PostHog | `${POSTHOG_PORT}` | `http://localhost:${POSTHOG_PORT}` |

---

## 🚀 Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) `>= 24.x`
- [Docker Compose](https://docs.docker.com/compose/install/) `>= 2.x`
- Minimum **4GB RAM** for grafana-suite, **8GB RAM** for analytics-suite
- Linux host recommended for production (Windows/macOS supported for development)

### 1. Clone the Repository

```bash
git clone https://github.com/Khushal-Savalakha/docker-self-hosted-monitoring.git
cd docker-self-hosted-monitoring
```

### 2. Start Grafana Suite

```bash
cd observability-stack/grafana-suite
docker-compose up -d
```

Access Grafana at `http://localhost:3011`
> Default credentials: `test_user` / `test_password` — **change these before production use**

### 3. Start Analytics Suite

```bash
cd observability-stack/analytics-suite
cp example.env .env
# Edit .env with your values
docker-compose up -d
```

Access SigNoz at `http://localhost:3301`
Access Graylog at `http://localhost:9001`
Access PostHog at `http://localhost:${POSTHOG_PORT}`

---

## 🔐 Environment Variables

Copy `example.env` to `.env` in the analytics-suite directory and configure:

```env
# ── Graylog ──────────────────────────────────────
GRAYLOG_PASSWORD_SECRET=        # Min 16 chars random string
GRAYLOG_ROOT_PASSWORD_SHA2=     # SHA256 of your admin password

# ── SigNoz / ClickHouse ───────────────────────────
CLICKHOUSE_HOST=clickhouse
CLICKHOUSE_PORT=9000
CLICKHOUSE_USER=
CLICKHOUSE_PASSWORD=
SIGNOZ_TELEMETRYSTORE_PROVIDER=clickhouse

# ── PostHog ───────────────────────────────────────
POSTHOG_SECRET_KEY=             # Long random secret key
POSTHOG_PORT=8000
POSTHOG_CLICKHOUSE_PASSWORD=
POSTHOG_DB_USER=
POSTHOG_DB_PASSWORD=
POSTHOG_DB_HOST=
POSTHOG_DB_PORT=5432
SERVER_IP=localhost
POSTHOG_DEBUG=0
```

> ⚠️ **Never commit your `.env` file.** It is excluded via `.gitignore`.

Generate a secure Graylog password hash:
```bash
echo -n "yourpassword" | sha256sum | awk '{print $1}'
```

---

## 🛠 Makefile Commands

Inside `analytics-suite/`:

```bash
make up        # Start all services detached
make down      # Stop all services
make restart   # Down + rebuild + up
make logs      # Tail all service logs
make build     # Build images
```

---

## 📊 Dashboards

Three pre-built Grafana dashboards are included in `grafana-suite/dashboards/`:

| Dashboard | Description |
|-----------|-------------|
| `container-log-monitoring.json` | Docker container log streams via Loki |
| `container-resource-observability.json` | Per-container CPU, memory, network via cAdvisor |
| `system-resource-utilization.json` | Host-level CPU, RAM, disk, network via Node Exporter |

To import: **Grafana → Dashboards → Import → Upload JSON file**

---

## 🤝 Contributing

Contributions are welcome. Please open an issue before submitting a pull request for significant changes.

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Commit using conventional commits: `feat:`, `fix:`, `chore:`, `docs:`
4. Push and open a Pull Request

---

## 👨‍💻 Author

**Khushal Savalakha**

- GitHub: [@Khushal-Savalakha](https://github.com/Khushal-Savalakha)
- Repository: [docker-self-hosted-monitoring](https://github.com/Khushal-Savalakha/docker-self-hosted-monitoring)

---

## 📄 License

This project is licensed under the terms of the [LICENSE](observability-stack/grafana-suite/LICENSE) file included in this repository.

---

<div align="center">

**Self-hosted. Open source. Zero vendor lock-in.**

⭐ Star this repo if it helped you — it helps others find it too.

</div>
