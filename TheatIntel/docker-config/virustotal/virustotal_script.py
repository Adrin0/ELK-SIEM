import os
import vt

API_KEY = "Paste VirusTotal API key"

def check_url(url):
    client = vt.Client(API_KEY)
    response = client.get_object(f"/urls/{vt.url_id(url)}")
    print(response.last_analysis_stats)
    client.close()

if __name__ == "__main__":
    check_url("http://example.com")
