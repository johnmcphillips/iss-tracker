import json
import requests

url = "https://api.wheretheiss.at/v1/satellites/25544"

def fetch_iss_location():
    response = requests.get(url)
    return {
        "latitude": response.json().get("latitude"),
        "longitude": response.json().get("longitude"),
        "velocity": response.json().get("velocity")
    }

def main():
    location = fetch_iss_location()
    print(json.dumps(location, indent=4))

if __name__ == '__main__':
    main()