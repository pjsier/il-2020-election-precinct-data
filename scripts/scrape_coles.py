import json
import sys

import requests
from arcgis2geojson import arcgis2geojson

# Worarkound for the fact that the existing tools aren't able to pull geometry
# More info: https://github.com/openaddresses/pyesridump/issues/43

if __name__ == "__main__":
    res = requests.get(
        (
            "https://www.co.coles.il.us/ccwgis/rest/services/CountyClerk/"
            "VoterPrecincts/MapServer/1/query"
        ),
        params={
            "geometry": json.dumps(
                {
                    "xmin": -945184.6898309961,
                    "ymin": 985773.8601766527,
                    "xmax": 1089578.2550459132,
                    "ymax": 1099730.9600179046,
                    "spatialReference": {"wkid": 102671},
                }
            ),
            "geometryType": "esriGeometryEnvelope",
            "inSR": 102100,
            "spatialRel": "esriSpatialRelIntersects",
            "outfields": "OBJECTID",
            "outSR": 102100,
            "featureEncoding": "esriDefault",
            "f": "json",
        },
    )
    data = res.json()
    features = []
    for obj in data["features"]:
        res = requests.get(
            "https://www.co.coles.il.us/ccwgis/rest/services/CountyClerk/"
            f"VoterPrecincts/MapServer/1/{obj['attributes']['OBJECTID']}?f=json"
        )
        features.append(arcgis2geojson(res.json()["feature"]))

    sys.stdout.write(json.dumps({"type": "FeatureCollection", "features": features}))
