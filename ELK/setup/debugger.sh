#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

echo "Updating system and installing prerequisites..."
apt update && apt upgrade -y
apt install -y wget curl apt-transport-https openjdk-11-jdk docker.io

echo "Installing docker-compose"
sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Setting up Elasticsearch GPG key and repository..."
sudo wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-archive-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

echo "Installing ELK Stack components..."
sudo apt update && sudo apt install -y elasticsearch logstash kibana

echo "Configuring Elasticsearch..."
sudo tee -a /etc/elasticsearch/elasticsearch.yml <<EOF
network.host: 0.0.0.0
discovery.type: single-node
EOF

echo "Configuring Kibana..."
cat <<EOF > /etc/kibana/kibana.yml
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]
EOF

echo "Setting up Logstash configuration..."
mkdir -p /etc/logstash/conf.d
sudo tee -a /etc/logstash/conf.d/logstash.conf <<EOF
input {
  beats {
    port => 5044
  }
}

output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
  }
}
EOF

echo "Creating Logstash settings file..."
sudo tee /etc/logstash/logstash.yml <<EOF
path.data: /var/lib/logstash
path.logs: /var/log/logstash
EOF

echo "Installing Filebeat..."
apt install -y filebeat
sudo tee -a /etc/filebeat/filebeat.yml <<EOF
filebeat.inputs:
  - type: log
    paths:
      - /var/log/*.log

output.logstash:
  hosts: ["localhost:5060"]
EOF

echo "Enabling and starting services..."
systemctl enable --now elasticsearch
systemctl enable --now kibana
systemctl enable --now logstash
systemctl enable --now filebeat

echo "Setting up Docker Compose for ELK stack..."
sudo mkdir -p /opt/elk
sudo tee -a /opt/elk/docker-compose.yml <<EOF
version: '3.3'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.10.1
    environment:
      - discovery.type=single-node
    ports:
      - "9201:9200"

  logstash:
    image: docker.elastic.co/logstash/logstash:7.10.1
    ports:
      - "5060:5044"
    volumes:
      - ./logstash-config:/usr/share/logstash/config

  kibana:
    image: docker.elastic.co/kibana/kibana:7.10.1
    ports:
      - "5602:5601"
EOF

echo "Starting Docker-based ELK stack..."
mkdir -p /var/log/elk
touch /var/log/elk/docker_errors.log
cd /opt/elk && sudo docker-compose up -d 2>> /var/log/elk/docker_errors.log

echo "Checking for Docker Compose errors..."
if grep -q "error" /var/log/elk/docker_errors.log; then
    echo "Errors detected during Docker Compose startup. Check /var/log/elk/docker_errors.log for details."
else
    echo "Docker Compose started successfully."
fi

echo "Setup complete! Access Kibana at http://<VM_IP>:5601"
