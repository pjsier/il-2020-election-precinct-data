import json
import math
import re
import sys

import requests

# Returned coordinates default to zoom of 19
WINDOW_ZOOM = 19


def window_point_to_lon_lat(wx, wy):
    """
    Based on w2LL function in https://richlandil.wthgis.com/tgis/tgisServer2.js?16122158
    """
    x = wx / (2 ** WINDOW_ZOOM)
    y = wy / (2 ** WINDOW_ZOOM)
    # Static values from code
    origin_x = 128.0
    origin_y = 128.0
    pixels_per_lon = 256 / 360
    pixels_per_lon_radian = 256 / (2 * math.pi)

    lon = (x - origin_x) / pixels_per_lon
    lat_radians = (y - origin_y) / (-pixels_per_lon_radian)
    lat = (2 * math.atan(math.exp(lat_radians)) - math.pi / 2) / (math.pi / 180)
    return lon, lat


def parse_geometry(xml_body):
    """Split out into a separate function to handle MultiPolygon features"""
    # Because the returned XML is pretty simple we can just use regex for parsing
    geom_strs = re.findall(r"(?<=\<poly\>).*?(?=\</)", xml_body)
    coord_lists = [parse_coords(geom_str) for geom_str in geom_strs]
    if len(coord_lists) == 1:
        return {"type": "Polygon", "coordinates": coord_lists}
    else:
        return {"type": "MultiPolygon", "coordinates": [coord_lists]}


def parse_coords(geom_str):
    """
    Based on drawPoly function https://richlandil.wthgis.com/tgis/tgisServer2.js?16122158
    """  # noqa
    geom_split = geom_str.split(",")
    point_count = int((len(geom_split) - 2) / 2)

    x_points = [int(geom_split[2])]
    y_points = [int(geom_split[3])]

    for i in range(1, point_count):
        x_points.append(x_points[i - 1] + int(geom_split[2 + i * 2]))
        y_points.append(y_points[i - 1] + int(geom_split[2 + i * 2 + 1]))

    window_points = zip(x_points, y_points)

    return [window_point_to_lon_lat(wx, wy) for wx, wy in window_points]


if __name__ == "__main__":
    layer_id = "1283"

    res = requests.get(
        "https://richlandil.wthgis.com/tgis/index.ashx",
        params={"action": "getFtrs", "dsid": layer_id, "i1": "0", "cnt": "21"},
    )

    # The text is returned invalid because it's using \x1e and \x1f as separators, but
    # immediately next to numbers which is causing Python to try and interpret the whole
    # sequence as a unicode character. \x1e separates groupings of (index, id, name) and
    # \x1f separates items within that, so we can use that to parse out items
    escaped_text = res.text.encode("unicode-escape").decode()
    feature_groups = [
        feature_group.split("\\x1f") for feature_group in escaped_text.split("\\x1e")
    ]

    features = []
    # Use the parsed feature IDs to request XML data for each feature
    for _, feat_id, feat_name in feature_groups:
        feat_res = requests.get(
            "https://richlandil.wthgis.com/tgis/getftr.aspx",
            params={"D": layer_id, "F": feat_id, "Z": "1"},
        )
        geometry = parse_geometry(feat_res.text)
        features.append(
            {
                "type": "Feature",
                "properties": {"precinct": feat_name},
                "geometry": geometry,
            }
        )

    json.dump({"type": "FeatureCollection", "features": features}, sys.stdout)
