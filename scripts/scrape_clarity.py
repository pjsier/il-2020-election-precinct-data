import json
import sys

import polyline
import requests

if __name__ == "__main__":
    _, url, authority = sys.argv
    res = requests.get(url)
    precincts = res.json()
    features = []
    for idx, p in enumerate(precincts):
        geom = polyline.decode(p["GCords"], 5, geojson=True)
        features.append(
            {
                "type": "Feature",
                "properties": {"Name": p["Name"], "Authority": authority, "index": idx},
                "geometry": {"type": "Polygon", "coordinates": [geom]},
            }
        )
    sys.stdout.write(json.dumps({"type": "FeatureCollection", "features": features}))
