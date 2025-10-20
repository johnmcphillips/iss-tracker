resource "aws_s3_object" "iss_icon" {
  bucket       = aws_s3_bucket.iss_tracker_bucket.id
  key          = "iss-icon.svg"
  source       = "${path.module}/images/iss-icon.svg"
  content_type = "image/svg+xml"
}
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.iss_tracker_bucket.id
  key          = "index.html"
  content_type = "text/html; charset=utf-8"

  content = <<EOT
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <base target="_top">
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" type="image/x-icon" href="https://${aws_s3_bucket.iss_tracker_bucket.bucket_regional_domain_name}/iss-icon.svg">
        <title>Terraform ISS Tracker</title>

        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
        <script src="https://cdn.jsdelivr.net/npm/leaflet.geodesic"></script>
        <script src="https://cdn.jsdelivr.net/npm/leaflet-ant-path@1.3.0/dist/leaflet-ant-path.min.js"></script>        
        <style>
            html, body {
                height: 100%;
                margin: 0;
            }
            .leaflet-container {
                height: 400px;
                width: 600px;
                max-width: 100%;
                max-height: 100%;
            }
            #map {
                width: 600px;
                height: 400px;
                margin: 0 auto;
                display: block;
                justify-content: center;
                align-items: center;
            }
            #stats {
                text-align: center;
                font-family: Arial, sans-serif;
                margin-bottom: 10px;
            }
            #page {
                text-align: center;
                font-family: Arial, sans-serif;
                margin-bottom: 20px;
            }
            #footer {
                text-align: center;
                font-family: Arial, sans-serif;
                font-size: 0.8em;
                color: #555;
                margin-top: 20px;
            }
        </style>
    </head>
    <body>
        <div id="page">
        <h1>Live ISS Tracker</h1>
        </div>
    <div id="stats">Latitude: -<br>Longitude: -<br> Velocity: -</div>
    <div id="map"></div>
    <script>
    const map = L.map('map', { worldCopyJump: true, preferCanvas: true }).setView([0, 0], 2);
    L.control.scale({ metric: true }).addTo(map);
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        updateWhenIdle: true,
        updateWhenZooming: false,
        keepBuffer: 2,    
	    maxZoom: 19,
        worldCopyJump: true,
        preferCanvas: true,
        inertia: true,
        zoomAnimation: true,
        markerZoomAnimation: false,
        tap: false,
	    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
	}).addTo(map);

    let line = null;
    let marker = null;

    async function trackISS() {
        try {
            const current = await fetch("https://${aws_s3_bucket.iss_tracker_bucket.bucket_regional_domain_name}/data/iss_location_latest.json", {cache: "no-store"});
            const history = await fetch("https://${aws_s3_bucket.iss_tracker_bucket.bucket_regional_domain_name}/data/history.json", {cache: "no-store"});
            
            const currentLocation = await current.json();
            const historyData = await history.json();

            const lat = Number(currentLocation.latitude);
            const lon = Number(currentLocation.longitude);
            const vel = Number(currentLocation.velocity);

            document.getElementById('stats').innerHTML =
                "Latitude:" +lat.toFixed(4) + " Longitude:"+ lon.toFixed(4) + " Velocity:"+ vel.toFixed(0) + " km/h";

            const latlon = historyData.map(p => [Number(p.latitude), Number(p.longitude)]);
            if (line) {
                map.removeLayer(line);
            }
            if (marker) {
                map.removeLayer(marker);
            }
            line = new L.Geodesic([latlon], {weight: 1.5, color: 'blue', opacity: 0.4, wrap: false, steps: 1}).addTo(map); 

            var issicon = L.icon({
                iconUrl: 'https://${aws_s3_bucket.iss_tracker_bucket.bucket_regional_domain_name}/iss-icon.svg',
                iconSize: [40, 40]
            });

	        marker = L.marker([lat, lon], {icon: issicon}).addTo(map)
            map.setView([lat, lon], map.getZoom());
            
        } catch (err) {
            console.error("No data:", err);
        }
    }
    trackISS();
    setInterval(trackISS, 30000);
    </script>
    <div id="footer">
        <p>Data sourced from <a href="https://wheretheiss.at/w/developer">"Where the ISS at?" REST API</a>. Built with Terraform and AWS.</p>
        <p>Author: <a href="https://github.com/johnmcphillips/iss-tracker">John McPhillips</a></p>
    </div>
    </body>
    </html>
    EOT
}