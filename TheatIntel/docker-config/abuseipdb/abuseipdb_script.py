import os
import requests

API_KEY = "Paste abuseipdb api key"
def check_ip(ip):
    url = f"https://api.abuseipdb.com/api/v2/check?ipAddress={ip}"
    headers = {"Key": API_KEY, "Accept": "application/json"}
    response = requests.get(url, headers=headers)
    print(response.json())

if __name__ == "__main__":
    check_ip("8.8.8.8")
