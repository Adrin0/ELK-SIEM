# ELK Machine Setup

The ELK machine hosts the Elasticsearch, Logstash, and Kibana stack for centralized security monitoring.

## Components
- **Elasticsearch:** Stores and indexes logs.
- **Logstash:** Processes and enriches log data.
- **Kibana:** Visualizes data from Elasticsearch.

## Setup Instructions

1. **Clone Repository and Navigate to ELK Folder:**
   ```bash
   git clone https://github.com/adrin0/ELK-SIEM
   cd ELK-SIEM/ELK

2. **Run Setup Script:**
    ```bash 
    chmod +x setup/setup.sh
    ./setup/setup.sh

3. **Verify Services:**
    - Access Kibana: `http://<ELK_VM_IP>:5602`
    - Test Elasticsearch: `curl -X GET "http://<ELK_VM_IP>:9200/_cluster/health?pretty"`

4. Configuration: 
    - Adjust 'config/docker-compose.yml' for custom settings.
    - Modify Logstash pipelines for additional data sources.