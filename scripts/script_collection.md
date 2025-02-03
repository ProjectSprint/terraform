# Install Redis on Ubuntu
```bash
sudo apt-get install lsb-release curl gpg &&\
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg &&\
sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg &&\
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list &&\
sudo apt-get update &&\
sudo apt-get install -y redis
```


# Install k6 Ubuntu
```bash
sudo gpg -k &&\
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69 &&\
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list &&\
sudo apt-get update &&\
sudo apt-get install -y k6
```

# Install Prometheus in Ubuntu arm64
```bash
### Prometheus
# Download and extract if not exists
[ ! -d ~/prometheus-3.1.0.linux-arm64 ] && {
    curl -L https://github.com/prometheus/prometheus/releases/download/v3.1.0/prometheus-3.1.0.linux-arm64.tar.gz | tar -xz -C ~
} &&\

# Copy binaries
[ ! -f /usr/local/bin/prometheus ] && sudo cp ~/prometheus-3.1.0.linux-arm64/prometheus /usr/local/bin &&\
[ ! -f /usr/local/bin/promtool ] && sudo cp ~/prometheus-3.1.0.linux-arm64/promtool /usr/local/bin &&\

# Create directories
sudo mkdir -p /etc/prometheus /var/lib/prometheus &&\

# Copy config
[ ! -f /etc/prometheus/prometheus.yml ] && sudo cp ~/prometheus-3.1.0.linux-arm64/prometheus.yml /etc/prometheus &&\

# Create user
id prometheus &>/dev/null || sudo useradd --no-create-home --shell /bin/false prometheus &&\

# Set permissions
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus &&\

# Create systemd service
[ ! -f /etc/systemd/system/prometheus.service ] && sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOL
[Unit]
Description=Prometheus Monitoring System
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOL

# Enable and start service
sudo systemctl enable --now prometheus
```

# Install Grafana & add Prometheus as datasource automatically
> ⚠️This step requires Prometheus to be installed first ⚠️
```bash
## Grafana (using curl for better proxy support)
sudo apt-get install -y apt-transport-https software-properties-common &&\
sudo mkdir -p /etc/apt/keyrings/ &&\
curl -sL https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null &&\
if ! grep -q "https://apt.grafana.com stable main" /etc/apt/sources.list.d/grafana.list; then
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list > /dev/null
fi &&\
sudo apt-get update &&\
sudo apt-get install -y grafana &&\

# Create prometheus to grafana data source
[ ! -f /etc/grafana/provisioning/datasources/prometheus.yml ] && sudo tee /etc/grafana/provisioning/datasources/prometheus.yml > /dev/null <<EOL
apiVersion: 1

datasources:
  - name: prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
    editable: true
    jsonData:
      httpMethod: POST
      timeInterval: 10s
      queryTimeout: 30s
      exemplarTraceIdDestinations: []
    version: 1
    secureJsonData: {}
EOL

sudo systemctl enable --now grafana-server

echo "installation done!"
```
