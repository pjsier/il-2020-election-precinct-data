import json
import sys

import polyline
import requests

if __name__ == "__main__":
    res = requests.get(
        "https://results.enr.clarityelections.com/WRC/Winnebago/107127/268257/json/cf87babd-eb26-4e37-bf3f-b3e4e62e2c52.json"  # noqa
    )
    precincts = res.json()
    features = []
    for p in precincts:
        geom = polyline.decode(p["GCords"], 5, geojson=True)
        features.append(
            {
                "type": "Feature",
                "properties": {"Name": p["Name"], "County": "Winnebago"},
                "geometry": {"type": "Polygon", "coordinates": [geom]},
            }
        )
    sys.stdout.write(json.dumps({"type": "FeatureCollection", "features": features}))
