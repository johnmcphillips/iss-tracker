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

def roll_up_history():
    history = [] 
    s3 = boto3.client("s3")
    response = s3.list_objects_v2(
        Bucket=bucket,
        Prefix="data/points/"
    )
    files = response.get("Contents", [])
    for file in files:
        response = s3.get_object(
            Bucket=bucket,
            Key=file["Key"])
        data = json.loads(response["Body"].read().decode("utf-8"))
        lat = data["latitude"]
        lon = data["longitude"]
        time = data["timestamp"]
        history.append({"latitude": lat, "longitude": lon, "timestamp": time})
    history.sort(key=lambda x: x["timestamp"], reverse=True)
    s3.put_object(
        Bucket=bucket,
        Key=f"data/history.json",
        Body=json.dumps(history),
        ContentType="application/json")

def lambda_handler(event, context):
    location = fetch_iss_location()
    s3 = boto3.client("s3")
    s3.put_object(
        Bucket=bucket, 
        Key=f"data/points/iss_location_{location['timestamp']}.json", 
        Body=json.dumps(location),
        ContentType="application/json")
    
    s3.put_object(
        Bucket=bucket,
        Key=f"data/iss_location_latest.json",
        Body=json.dumps(location),
        ContentType="application/json")
    
    roll_up_history()
    
    return {
        "statusCode": 200,
        "body": json.dumps(location)
    }