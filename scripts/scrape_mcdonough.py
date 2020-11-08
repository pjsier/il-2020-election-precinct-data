import json
import sys

import requests
from arcgis2geojson import arcgis2geojson

# Worarkound for the fact that the existing tools aren't able to pull geometry
# More info: https://github.com/openaddresses/pyesridump/issues/43

if __name__ == "__main__":
    res = requests.get(
        "https://gis.wiu.edu/arcgis/rest/services/precinct_map/MapServer/4/query",
        params={
            "geometry": json.dumps(
                {
                    "xmin": 2089274.6248927526,
                    "ymin": 1314656.3750297576,
                    "xmax": 2219153.7499765046,
                    "ymax": 1447575.8749382633,
                    "spatialReference": {"wkid": 102672, "latestWkid": 3436},
                }
            ),
            "geometryType": "esriGeometryEnvelope",
            "spatialRel": "esriSpatialRelIntersects",
            "outfields": "OBJECTID_12",
            "featureEncoding": "esriDefault",
            "f": "json",
        },
    )
    data = res.json()
    features = []
    for obj in data["features"]:
        res = requests.get(
            "https://gis.wiu.edu/arcgis/rest/services/precinct_map/MapServer/4/"
            f"{obj['attributes']['OBJECTID_12']}?f=json"
        )
        features.append(arcgis2geojson(res.json()["feature"]))

    sys.stdout.write(json.dumps({"type": "FeatureCollection", "features": features}))
