resource "aws_s3_object" "index_html" {
    bucket = aws_s3_bucket.iss_tracker_bucket.id
    key = "index.html"
    content_type = "text/html; charset=utf-8"

    content = <<EOT
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <base target="_top">
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />

        <title>Terraform ISS Tracker</title>

        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
        
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
        </style>
    </head>
    <body>
        <div id="page">
        <h1>Live ISS Tracker</h1>
        <p>Built with Terraform, powered by <a href="https://api.wheretheiss.at/v1/satellites/25544">https://api.wheretheiss.at/v1/satellites/25544</a></p>
        <p>Source: <a href="https://github.com/johnmcphillips/iss-tracker">https://github.com/johnmcphillips/iss-tracker</a></p>
        </div>
    <div id="stats">Latitude: -<br>Longitude: -<br> Velocity: -</div>
    <div id="map"></div>
    <script>
    async function trackISS() {
        try {
            const response = await fetch("${("https://${aws_s3_bucket.iss_tracker_bucket.bucket_regional_domain_name}/iss_location_latest.json")}");
            const data = await response.json();

            const lat = data.latitude;
            const lon = data.longitude;
            const vel = data.velocity;
            document.getElementById('stats').innerHTML =
                "Latitude:" +lat.toFixed(4) + " Longitude:"+ lon.toFixed(4) + " Velocity:"+ vel.toFixed(0) + " km/h";
	        const map = L.map('map').setView([lat, lon], 5);

            const tiles = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
	        	maxZoom: 19,
	        	attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
	        }).addTo(map);
        
        
	        const circle = L.circle([lat, lon], {
	        	color: 'red',
	        	fillColor: '#f03',
	        	fillOpacity: 0.5,
	        	radius: 500
	        }).addTo(map);
        } catch (err) {
            console.error("No data:", err);
        }
    }
    trackISS();
    </script>
    </body>
    </html>
    EOT
}