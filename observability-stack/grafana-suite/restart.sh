cd /var/www/html/grafana

echo "Stopping all containers..."
docker compose down -v

echo "Creating Loki directories..."
sudo mkdir -p data/loki/chunks
sudo mkdir -p data/loki/boltdb-shipper-active
sudo mkdir -p data/loki/boltdb-shipper-cache
sudo mkdir -p data/loki/compactor
sudo mkdir -p data/loki/rules
sudo mkdir -p data/loki/{chunks,rules,rules-temp,tsdb-index,tsdb-cache,compactor}

echo "Setting permissions..."
sudo chmod -R 777 data/loki
sudo chown -R 472:472 data/grafana 2>/dev/null || true
sudo chown -R 65534:65534 data/prometheus 2>/dev/null || true


echo "Starting containers..."
docker compose up -d --build

echo "Waiting for services to start..."
sleep 15

echo "Checking container status..."
docker compose ps

echo ""
echo "Checking Promtail logs..."
docker compose logs promtail | tail -30

echo ""
echo "Checking Loki logs..."
docker compose logs loki | tail -20
