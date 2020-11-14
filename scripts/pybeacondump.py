import collections
import copy
import http.client
import json
import re
import sys
import urllib.parse

import bs4
import requests
from geomet import wkt

"""
Based on conversation and code from https://github.com/openaddresses/machine/issues/580
"""

BEACON_HEADERS = {
    "Content-Type": "application/json",
    "User-Agent": "OA",
}

BODY_TEMPLATE = {
    "layerId": None,
    "useSelection": False,
    "ext": {"minx": 0, "miny": 0, "maxx": 40000000, "maxy": 40000000},
    "wkt": None,
    "spatialRelation": 1,
    "featureLimit": 1,
}

name_value_pattern = re.compile(r"^(\w+) = (.*)$", re.M)
coordinate_pattern = re.compile(r"(?P<x>-?\d+(\.\d+)?)\s+(?P<y>-?\d+(\.\d+)?)")


def get_query_url(start_url):
    """Create a query URL including a dynamically assigned QPS value"""
    res = requests.get(start_url)
    soup = bs4.BeautifulSoup(res.text, "html.parser")
    config_script = soup.find_all("script", attrs={"type": "text/javascript"})[-1]
    script_content = config_script.contents[0]
    script_data_str = re.search(r"(?<=\= )\{.*\}(?=;)", script_content).group()
    script_data = json.loads(script_data_str)

    return (
        "https://beacon.schneidercorp.com/api/beaconCore/GetVectorLayer?QPS="
        + script_data["QPS"]
    )


def get_connection(raw_url):
    """ Return an HTTPConnection and URL path for a starting Beacon URL.
    
        Expects a raw URL similar to:
        https://beacon.schneidercorp.com/api/beaconCore/GetVectorLayer?QPS=xxxx
    """
    # Safari developer tools sneaks in some zero-width spaces:
    # http://www.fileformat.info/info/unicode/char/200B/index.htm
    url = raw_url.replace("\u200b", "")

    scheme, host, path, _, query, _ = urllib.parse.urlparse(url)
    layer_path = urllib.parse.urlunparse(("", "", path, None, query, None))

    if scheme == "https":
        return http.client.HTTPSConnection(host), layer_path
    elif scheme == "http":
        return http.client.HTTPConnection(host), layer_path


def get_starting_bbox(conn, layer_path, layer_id, radius_km=200):
    """ Retrieves a bounding box tuple for a Beacon layer and radius in km.
    
        This is meant to be an overly-large, generous bbox that should
        encompass any reasonable county or city data source.
    """
    body = copy.deepcopy(BODY_TEMPLATE)
    body["layerId"] = int(layer_id)

    conn.request("POST", url=layer_path, body=json.dumps(body), headers=BEACON_HEADERS)

    resp = conn.getresponse()

    if resp.status not in range(200, 299):
        raise RuntimeError("Bad status in get_starting_bbox")

    results = json.load(resp)
    wkt = results.get("d", [{}])[0].get("WktGeometry", None)

    if not wkt:
        raise RuntimeError("Missing WktGeometry in get_starting_bbox")

    match = coordinate_pattern.search(wkt)

    if not match:
        raise RuntimeError("Unparseable WktGeometry in get_started_bbox")

    x, y = float(match.group("x")), float(match.group("y"))
    xmin, ymin = x - radius_km * 1000, y - radius_km * 1000
    xmax, ymax = x + radius_km * 1000, y + radius_km * 1000

    return xmin, ymin, xmax, ymax


def partition_bbox(xmin, ymin, xmax, ymax):
    """ Cut a bounding box into four smaller bounding boxes.
    """
    xmid, ymid = xmin / 2 + xmax / 2, ymin / 2 + ymax / 2

    return [
        (xmin, ymin, xmid, ymid),
        (xmin, ymid, xmid, ymax),
        (xmid, ymin, xmax, ymid),
        (xmid, ymid, xmax, ymax),
    ]


def get_features(conn, layer_path, layer_id, bbox, limit=0, depth=0):
    """ Return a list of features after geographically searching a layer.
    """
    body = copy.deepcopy(BODY_TEMPLATE)
    body["layerId"], body["featureLimit"] = int(layer_id), limit
    body["ext"] = dict(minx=bbox[0], miny=bbox[1], maxx=bbox[2], maxy=bbox[3])

    conn.request("POST", url=layer_path, body=json.dumps(body), headers=BEACON_HEADERS)

    resp = conn.getresponse()

    if resp.status not in range(200, 299):
        raise RuntimeError("Bad status in get_features")

    records = json.load(resp).get("d", [])

    if limit == 0:
        # This is our first time through and we don't actually know how many
        # things there are. Assume that the current count is the limit.
        limit = len(records)

    if len(records) >= limit:
        # There are too many records, recurse!
        # This also happens the first time through before we know anything.
        bbox1, bbox2, bbox3, bbox4 = partition_bbox(*bbox)
        return (
            get_features(conn, layer_path, layer_id, bbox1, limit, depth + 1)
            + get_features(conn, layer_path, layer_id, bbox2, limit, depth + 1)
            + get_features(conn, layer_path, layer_id, bbox3, limit, depth + 1)
            + get_features(conn, layer_path, layer_id, bbox4, limit, depth + 1)
        )

    # We are good, make some GeoJSON.
    print(" " * depth, "found", len(records), "in", bbox, file=sys.stderr)
    return [make_feature(record) for record in records]


def extract_properties(record):
    """ Get a dictionary of GeoJSON feature properties for a record.
    """
    properties = collections.OrderedDict()

    html1 = record.get("TipHtml", "").replace("\r\n", "\n")
    html2 = record.get("ResultHtml", "").replace("\r\n", "\n")

    soup1 = bs4.BeautifulSoup(html1, "html.parser")
    soup2 = bs4.BeautifulSoup(html2, "html.parser")

    for text in soup1.find_all(text=name_value_pattern):
        properties.update({k: v for (k, v) in name_value_pattern.findall(text)})

    for text in soup2.find_all(text=name_value_pattern):
        properties.update({k: v for (k, v) in name_value_pattern.findall(text)})

    return properties


def extract_geometry(record):
    """ Get a GeoJSON geometry object for a record.
    """
    prop = extract_properties(record)

    try:
        geom = dict(type="Point", coordinates=[float(prop["Long"]), float(prop["Lat"])])
    except ValueError:
        geom = None

    return geom


def make_feature(record):
    """ Get a complete GeoJSON feature object for a record.
    """
    return dict(
        type="Feature",
        id=record.get("Key"),
        geometry=wkt.loads(record.get("WktGeometry")),
        properties=extract_properties(record),
    )


if __name__ == "__main__":
    _, start_url, layer_id, filename = sys.argv
    query_url = get_query_url(start_url)

    conn, layer_path = get_connection(query_url)
    bbox = get_starting_bbox(conn, layer_path, layer_id)
    print(bbox, file=sys.stderr)

    features = get_features(conn, layer_path, layer_id, bbox)
    geojson = dict(type="FeatureCollection", features=list(features))

    if filename == "-":
        json.dump(geojson, sys.stdout)
    else:
        with open(filename, "w") as f:
            json.dump(geojson, f)
