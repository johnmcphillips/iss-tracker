import time, json, requests, boto3, os

url = "https://api.wheretheiss.at/v1/satellites/25544"
bucket = os.environ.get("BUCKET_NAME")

def fetch_iss_location():
    response = requests.get(url)
    return {
        "latitude": response.json().get("latitude"),
        "longitude": response.json().get("longitude"),
        "velocity": response.json().get("velocity"),
        "timestamp": response.json().get("timestamp")
    }

def lambda_handler(event, context):
    location = fetch_iss_location()
    s3 = boto3.client("s3")
    s3.put_object(
        Bucket=bucket, 
        Key=f"iss_location_{location['timestamp']}.json", 
        Body=json.dumps(location))
    s3.put_object(
        Bucket=bucket,
        Key=f"iss_location_latest.json",
        Body=json.dumps(location))
    return {
        "statusCode": 200,
        "body": json.dumps(location)
    }