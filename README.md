# Incident Response Platform Project

This project involves setting up an incident response platform using Docker, VirtualBox, and Virtual Machines (VMs) to provide a comprehensive security monitoring and automation solution. The platform is configured with a SIEM (Security Information and Event Management) stack (ELK), threat intelligence, and automated response capabilities.

## Table of Contents
1. [Project Overview](#project-overview)
2. [Requirements](#requirements)
3. [Architecture](#architecture)
4. [Setup Instructions](#setup-instructions)
   - [VM Configuration](#vm-configuration)
   - [Network Configuration](#network-configuration)
   - [Environment Setup](#environment-setup)
5. [Platform Components](#platform-components)
   - [SIEM Stack (ELK)](#siem-stack-elk)
   - [Threat Intelligence Integration](#threat-intelligence-integration)
   - [Automation Scripts](#automation-scripts)
6. [Testing & Usage](#testing--usage)
7. [Future Enhancements](#future-enhancements)

---

## Project Overview

The Incident Response Platform is a lab environment designed for security monitoring, threat detection, and automated responses. This project is built using Docker containers and VirtualBox VMs to simulate an enterprise network environment, capturing logs, enriching them with threat intelligence, and responding to potential incidents.

## Requirements

- **Oracle VirtualBox** (for virtual machine management)
- **PowerShell** (for automated network and VM configuration)
- **Docker & Docker Compose** (for containerized services)
- **Ubuntu Server** (for hosting ELK stack and threat intelligence)
- **Kali Linux** (for Vulnerable/Testing VM)
- **Python** (for automation scripts)

## Architecture

The platform is organized into three primary VMs, each serving a specific purpose within the internal network.

| VM Name               | OS             | Role                                       |
|-----------------------|----------------|--------------------------------------------|
| **SIEM & Monitoring** | Ubuntu Server  | Hosts ELK Stack and Filebeat for log collection |
| **Threat Intel & Automation** | Ubuntu Server | Runs threat intel and automation scripts in Docker |
| **Vulnerable/Testing** | Kali Linux | Generates test logs and malicious activity |

### Network Setup

All VMs are connected to an internal network (`AIRTIP-Net`) configured with DHCP. This network is isolated to simulate a secure lab environment, and each VM is assigned a static IP for easy access between components.

## Setup Instructions

### Prerequisites
- **Oracle VirtualBox**: For VM management.
- **Ubuntu Server**: For ELK Stack and Threat Intelligence VMs.
- **Kali Linux**: For attack simulation.
- **Docker & Docker Compose**: To run containerized services.

### Steps to Deploy
### VM Configuration
**Download VM Images**

- [Ubuntu Server](https://ubuntu.com/download/server)
- [Kali Linux](https://www.kali.org/get-kali/#kali-virtual-machines)

**For each VM, ensure the following hardware specifications:**
- **ELK-Server**: 4 Cores, 8gb RAM, 25gb Storage
- **Threat-Intel-Server**: 2 Cores, 4gb RAM, 25gb Storage
- **Kali VM**: 2 Cores, 2gb RAM, 25gb Storage
- **Network**: Internal network adapter set to `AIRTIP-Net` and NAT network adapter enabled


### Network Configuration

#### Step 1: Configure VMs for Internet Access

1. **Attach a NAT Network Adapter to each VM**
    - Open the VirtualBox settings for each VM.
    - Under the Network tab, ensure the first adapter is set to NAT for internet access.

#### Step 2: Create and Configure an Internal Network

1. **Create an Internal Network in VirtualBox**
    - Open File > Host Network Manager in VirtualBox.
    - Configure the IP range (e.g., 192.168.56.1/24) and enable DHCP.
    - (Optional) Use PowerShell to configure DHCP:
    ```powershell
    VBoxManage dhcpserver add --network=AIRTIP-Net --server-ip=192.168.56.1 --lower-ip=192.168.56.2 --upper-ip=192.168.56.24 --netmask=255.255.255.0 --enable
    ```
2. **Assign Static IPs to each VM**
**IP Addresses**
- **ELK-Server**: 192.168.56.7
- **Threat-Intel-Server**: 192.168.56.8
- **Kali-VM**: 192.168.56.9

### Environment Setup

1. **Configure SSH on both Ubuntu Servers and Kali VM, then Login to each server**

   **Ubuntu**:
      - [Ubuntu Setup](docs/Ubuntu-Setup.md)

   **Kali/Ubuntu**:
      - [Kali SSH Setup](docs/Kali-SSH-Setup.md)
- On Kali machine, SSH into each server.
   ```bash
   ssh adrino@192.168.56.7
   ssh adrino@192.168.56.8
   ```
2. **Setup the ELK VM:**
- **Clone the Repository**
   ```bash
   git clone https://github.com/Adrin0/ELK-SIEM
   cd ELK-SIEM
   ```
- **Run the setup script**
   ```bash
   chmod +x setup-ELK.sh
   ./setup-ELK.sh
   ```   
- **Verify Services**
    - Kibana: http://<ELK_VM_IP>:5601
    - Elasticsearch: http://<ELK_VM_IP>:9200

3. **Setup the Threat Intelligence VM:**
- **Clone the Repository**
   ```bash
   git clone https://github.com/Adrin0/ELK-SIEM
   cd ELK-SIEM
   ```
- **Run the setup script**
   ```bash
   chmod +x setup-threat-intel.sh
   ./setup-threat-intel.sh
   ```   
- **Obtain API keys for AbuseIPDB and VirutsTotal and store them in .env**
    1. AbuseIPDB API Key:
    - Go to the AbuseIPDB website.
    - Create an account or log in.
    - Navigate to your API Keys section under account settings.
    - Generate an API key.

    2. VirusTotal API Key:
    - Visit VirusTotal.
    - Sign up or log in to your account.
    - Go to your profile settings and find the API Key section.
    - Copy the API key provided.
    
    3. Create a .env File:
    ```
    cd /opt/threat-intel
    nano .env
    ```
    4. Add API Keys to File:
    ```env
    ABUSEIPDB_API_KEY=your_abuseipdb_api_key
    VIRUSTOTAL_API_KEY=your_virustotal_api_key
    ```
    5. Verify Configuration:
    - Restart the Docker services to apply the changes:
    ```bash
    cd /opt/threat-intel
    docker-compose down
    docker-compose up -d
    ```
    6. Verify Environment Variables
    - Check that containers are running correctly:
    ```bash
    docker ps
    ```
    - Ensure API keys are used properly by testing threat_intel.py service:
    ```bash
    curl -X POST -H "Content-Type: application/json" -d '{"ip": "8.8.8.8"}' http://localhost:5000/enrich
    ```
4. **Integrate Threat Intelligence with ELK**
- Update the ELK Stack's Logstash configuration to include enriched data from the threat intelligence services. Modify /etc/logstash/conf.d/logstash.conf on the ELK VM:
    ```conf
        filter {
    if [source] =~ /logs/ {
        ruby {
        code => "
            require 'net/http'
            require 'json'
            uri = URI('http://<threat-intel-ip>:5000/enrich')
            response = Net::HTTP.post(uri, { 'ip' => event.get('ip') }.to_json, 'Content-Type' => 'application/json')
            enrichment = JSON.parse(response.body)
            event.set('threat_level', enrichment['threat_level'])
        "
        }
    }
    }
    ```
5. **Automate Incident Response:**
    - Test the automation script incident_response.py to block malicious IPs. Verify that the Docker container is running:
    ```bash
    docker logs incident_response
    ```
    - Test if UFW is automatically blocking ports:
    ```bash
    sudo ufw status
    ```

6. **Configure Filebeat on Threat Intel Machine**
    - edit setup-threat-intel.sh to send logs to ELK server
    ```bash
    nano setup-threat-intel.sh
    ```

    - change <ELK_IP> to the IP of the ELK machine.
    ```bash
        filebeat.inputs:
    - type: log
    enabled: true
    paths:
        - /var/log/*.log

    output.elasticsearch:
    hosts: ["<ELK_IP>:9200"]
    ```
    
    - restart filebeat service:
    ```bash
    sudo systemctl restart filebeat
    ```
    - Verify Filebeat is running correctly: 
    ```bash
    sudo systemctl status filebeat   # Check the status of the service
    sudo filebeat test output        # Confirm that Filebeat is correctly connecting to Elasticsearch
    sudo filebeat test config        #Validate the configuration to ensure no error

    ```
