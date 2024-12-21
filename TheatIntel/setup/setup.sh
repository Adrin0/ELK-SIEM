#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

echo "Updating system and installing prerequisites..."
apt update && apt upgrade -y
apt install -y python3 python3-pip python3-venv docker.io curl

echo "Installing docker-compose"
sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#echo "Setting up project directories..."
#mkdir -p /opt/threat-intel /opt/incident-response
#cd /opt/threat-intel

#echo "Creating Python virtual environment..."
#python3 -m venv /opt/threat-intel/env
#source /opt/threat-intel/env/bin/activate

#echo "Installing Python dependencies..."
#pip install -r requirements-threat-intel.txt

echo "Setting up Docker for Threat Intelligence Services..."
cat <<EOF > /opt/threat-intel/docker-compose.yml
version: '3.3'
services:
  abuseipdb:
    image: python:3.8
    container_name: abuseipdb_checker
    volumes:
      - ./scripts:/app
    working_dir: /app
    command: python threat_intel.py
    environment:
      - API_KEY=${ABUSEIPDB_API_KEY}
EOF

echo "Setting up Automation Scripts..."
mkdir -p /opt/incident-response/scripts
cp /opt/threat-intel/scripts/incident_response.py /opt/incident-response/scripts/

cat <<EOF > /opt/incident-response/docker-compose.yml
version: '3.3'
services:
  incident-response:
    image: python:3.8
    container_name: incident_response
    volumes:
      - ./scripts:/app
    working_dir: /app
    command: python incident_response.py
EOF

echo "Starting Threat Intelligence Services..."
cd /opt/threat-intel
docker-compose up -d

echo "Starting Incident Response Automation..."
cd /opt/incident-response
docker-compose up -d

# Installing and Configuring Filebeat
echo "Installing Filebeat for log forwarding..."
apt install -y filebeat

echo "Configuring Filebeat to send logs to the ELK server..."
cat <<EOF > /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log

output.elasticsearch:
  hosts: ["<ELK_IP>:9200"]
EOF

echo "Enabling and starting Filebeat service..."
systemctl enable filebeat
systemctl start filebeat

echo "Verifying Filebeat configuration..."
filebeat test output
filebeat test config

echo "Setup complete! Threat Intelligence, Automation, and Filebeat are ready."