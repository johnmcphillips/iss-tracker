## Terraform Powered International Space Station Tracker

![ISS Tracker Screenshot](images/map.png)

- No external building or tools required.
- Utilizes the https://api.wheretheiss.at/v1/satellites/25544 free ISS tracking API to pull the latest ISS stats.
- GET and store every 5 minutes, keeping latest and historical timestamps.
- Render position of the ISS over OpenStreetMaps

### Todo:
Add historical position tracking to utilize the stored GET calls.

![ISS JSON](images/json.png)