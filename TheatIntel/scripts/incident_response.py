import os
import requests
import subprocess

# Environment variables
ELASTICSEARCH_URL = "<ELK_IP>:9200" # replace <ELK_IP> with ip of ELK machine
MALICIOUS_LOG_INDEX = "filebeat-*"

def get_malicious_ips():
    try:
        query = {
            "query": {
                "term": {
                    "malicious": True
                }
            }
        }
        response = requests.get(f"{ELASTICSEARCH_URL}/{MALICIOUS_LOG_INDEX}/_search", json=query)
        response.raise_for_status()
        hits = response.json()["hits"]["hits"]
        return [hit["_source"]["ip"] for hit in hits]
    except Exception as e:
        print(f"Error fetching malicious IPs: {e}")
        return []

def block_ip(ip):
    try:
        subprocess.run(["sudo", "ufw", "deny", "from", ip], check=True)
        print(f"Blocked IP: {ip}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to block IP {ip}: {e}")

def main():
    print("Fetching malicious IPs...")
    malicious_ips = get_malicious_ips()

    for ip in malicious_ips:
        print(f"Processing IP: {ip}")
        block_ip(ip)

if __name__ == "__main__":
    main()
