import json, requests, boto3

url = "https://api.wheretheiss.at/v1/satellites/25544"

def fetch_iss_location():
    response = requests.get(url)
    return {
        "latitude": response.json().get("latitude"),
        "longitude": response.json().get("longitude"),
        "velocity": response.json().get("velocity")
    }

def lambda_handler(event, context):
    location = fetch_iss_location()
    print(json.dumps(location, indent=4))
    return {
        "statusCode": 200,
        "body": json.dumps(location)
    }

if __name__ == "__main__":
    lambda_handler({}, {})