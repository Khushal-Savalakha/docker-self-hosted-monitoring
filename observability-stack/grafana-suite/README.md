### 📊 Monitoring & Logging Stack

* **Prometheus** – Collects and stores time-series metrics such as CPU, memory, and application performance data.

* **Node Exporter** – Exposes system-level metrics (CPU, RAM, disk, network) from the host machine for Prometheus.

* **cAdvisor** – Provides container-level metrics like resource usage and performance statistics for Docker containers.

* **Grafana** – Visualizes metrics and logs through interactive dashboards and supports alerting.

* **Loki** – Efficiently stores and manages logs, optimized for integration with Grafana.

* **Promtail** – Collects logs from the system and containers, then forwards them to Loki.
