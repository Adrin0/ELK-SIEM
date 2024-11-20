import os
import requests
from flask import Flask, request, jsonify

# Load API keys from environment variables
ABUSEIPDB_API_KEY = os.getenv('ABUSEIPDB_API_KEY')
VIRUSTOTAL_API_KEY = os.getenv('VIRUSTOTAL_API_KEY')

app = Flask(__name__)

@app.route('/enrich', methods=['POST'])
def enrich_data():
    data = request.get_json()
    ip = data.get('ip')

    if not ip:
        return jsonify({"error": "IP address is required"}), 400

    # Query AbuseIPDB
    abuseipdb_response = query_abuseipdb(ip)
    # Query VirusTotal
    virustotal_response = query_virustotal(ip)

    # Combine responses
    result = {
        "ip": ip,
        "abuseipdb": abuseipdb_response,
        "virustotal": virustotal_response,
        "threat_level": max(abuseipdb_response.get("threat_score", 0),
                            virustotal_response.get("threat_score", 0))
    }

    return jsonify(result)

def query_abuseipdb(ip):
    url = f"https://api.abuseipdb.com/api/v2/check"
    headers = {"Key": ABUSEIPDB_API_KEY, "Accept": "application/json"}
    params = {"ipAddress": ip, "maxAgeInDays": 90}

    try:
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()
        return {"threat_score": data["data"]["abuseConfidenceScore"]}
    except Exception as e:
        return {"error": str(e)}

def query_virustotal(ip):
    url = f"https://www.virustotal.com/api/v3/ip_addresses/{ip}"
    headers = {"x-apikey": VIRUSTOTAL_API_KEY}

    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        data = response.json()
        malicious_count = data["data"]["attributes"]["last_analysis_stats"]["malicious"]
        return {"threat_score": malicious_count}
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
