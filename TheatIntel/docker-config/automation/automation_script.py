import os

def block_ip(ip):
    print(f"Blocking IP: {ip}")
    # Example: os.system(f"iptables -A INPUT -s {ip} -j DROP")

if __name__ == "__main__":
    malicious_ips = ["192.168.1.1", "10.0.0.2"]
    for ip in malicious_ips:
        block_ip(ip)
