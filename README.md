# Incident Response Platform Project

This project involves setting up an incident response platform using Docker, VirtualBox, and Virtual Machines (VMs) to provide a comprehensive security monitoring and automation solution. The platform is configured with a SIEM (Security Information and Event Management) stack (ELK), threat intelligence, and automated response capabilities.

## Table of Contents
1. [Project Overview](#project-overview)
2. [Requirements](#requirements)
3. [Architecture](#architecture)
   - [Network Setup](#network-setup)
4. [Setup Instructions](#setup-instructions)
   - [Prerequisites](#prerequisites)
   - [VM Configuration](#vm-configuration)
   - [Network Configuration](#network-configuration)
   - [Environment Setup](#environment-setup)
5. [Integration](#integration)
   - [Threat Intelligence with ELK](#threat-intelligence-with-elk)
   - [Incident Response Automation](#incident-response-automation)
6. [Testing & Validation](#testing--validation)


---

## Project Overview

- Capture and analyze logs.
- Enrich logs with threat intelligence.
- Automate incident responses.

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
1. Install **VirtualBox**.
2. Download VM images:
   - [Ubuntu Server](https://ubuntu.com/download/server)
   - [Kali Linux](https://www.kali.org/get-kali/#kali-virtual-machines)

### VM Configuration
1. **Resources**:
   - ELK-Server: 4 Cores, 8GB RAM, 100GB Storage.
   - Threat-Intel-VM: 2 Cores, 4GB RAM, 25GB Storage.
   - Kali-VM: 2 Cores, 2GB RAM, 25GB Storage.

2. **Network**:
   - Adapter 1: NAT (Internet).
   - Adapter 2: Internal network (`AIRTIP-Net`).

**IP Addresses**
- **ELK-Server**: 192.168.56.7
- **Threat-Intel-Server**: 192.168.56.8
- **Kali-VM**: 192.168.56.9

### Environment Setup

1. **Configure SSH on both Ubuntu Servers and Kali VM, then Login to each server**

   **Ubuntu**:
      - [Ubuntu Setup](docs/Ubuntu-Setup.md)

   **Kali**:
      - [Kali SSH Setup](docs/Kali-SSH-Setup.md)
- On Kali machine, SSH into each server.
   ```bash
   ssh adrino@192.168.56.7
   ssh adrino@192.168.56.8
   ```
2. **Setup the ELK VM:**
- [ELK Machine Setup](ELK/README.md): Instructions for configuring Elasticsearch, Logstash, and Kibana.

3. **Setup the Threat Intelligence VM:**
- [Threat Intelligence Machine Setup](ThreatIntel/README.md): Instructions for setting up threat intelligence and automation services.

Ensure each setup is completed in its respective environment before proceeding with integration.

4. **Integrate Threat Intelligence with ELK**
- Update the ELK Stack's Logstash configuration to include enriched data from the threat intelligence services. Modify /ELK/config/logstash.conf on the ELK VM:
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
    
## Testing & Validation

- Access Kibana: `http://<ELK_VM_IP>:5602`
- Verify Threat Intel API integration:
```bash
curl -X POST -H "Content-Type: application/json" -d '{"ip": "8.8.8.8"}' http://localhost:5000/enrich