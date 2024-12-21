# Threat Intelligence and Automation Machine Setup

This machine enriches logs with threat intelligence and provides automated responses to security incidents.

## Components
- **AbuseIPDB Integration:** Checks IP reputation.
- **VirusTotal Integration:** Scans file hashes and URLs.
- **Automation Scripts:** Block malicious IPs using UFW.

## Setup Instructions

1. **Clone Repository and Navigate to ThreatIntel Folder:**
   ```bash
   git clone https://github.com/adrin0/ELK-SIEM
   cd ELK-SIEM/ThreatIntel

2. **Configure Environtment Variables:**
    - Create a '.env' file with API keys for Abuse IPDB and VirusTotal:
    ```env
    ABUSEIPDB_API_KEY=your_abuseipdb_api_key
    VIRUSTOTAL_API_KEY=your_virustotal_api_key

3. **Run Setup Script:**
    ```bash
    chmod +x setup/setup.sh
    ./setup/setup.sh

4. **Verify Services:**
- Test AbuseIPDB Integrations:
    ```bash
    curl -X POST -H "Content-Type: application/json" -d '{"ip": "8.8.8.8"}' http://localhost:5000/enrich

- Check Docker container status:
    ```bash
    docker ps