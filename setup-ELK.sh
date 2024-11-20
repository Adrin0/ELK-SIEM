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
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list

echo "Installing ELK Stack components..."
apt update && apt install -y elasticsearch logstash kibana

echo "Configuring Elasticsearch..."
cat <<EOF > /etc/elasticsearch/elasticsearch.yml
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
cat <<EOF > /etc/logstash/conf.d/logstash.conf
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

echo "Installing Filebeat..."
apt install -y filebeat
cat <<EOF > /etc/filebeat/filebeat.yml
filebeat.inputs:
  - type: log
    paths:
      - /var/log/*.log

output.logstash:
  hosts: ["localhost:5044"]
EOF

echo "Enabling and starting services..."
systemctl enable --now elasticsearch
systemctl enable --now kibana
systemctl enable --now logstash
systemctl enable --now filebeat

echo "Setting up Docker Compose for ELK stack..."
mkdir -p /opt/elk
cat <<EOF > /opt/elk/docker-compose.yml
version: '3.3'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.10.1
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"

  logstash:
    image: docker.elastic.co/logstash/logstash:7.10.1
    ports:
      - "5044:5044"
    volumes:
      - ./logstash-config:/usr/share/logstash/config

  kibana:
    image: docker.elastic.co/kibana/kibana:7.10.1
    ports:
      - "5601:5601"
EOF

echo "Starting Docker-based ELK stack..."
cd /opt/elk && docker-compose up -d

echo "Setup complete! Access Kibana at http://<VM_IP>:5601"
