import csv
import json
import sys
from collections import defaultdict

COLUMNS = [
    "id",
    "authority",
    "place",
    "ward",
    "precinct",
    "registered",
    "ballots",
    "us-president-dem",
    "us-president-rep",
    "us-president-votes",
    "il-constitution-yes",
    "il-constitution-no",
    "il-constitution-votes",
]

if __name__ == "__main__":
    data = json.load(sys.stdin)
    results_dict = defaultdict(dict)

    for feature in data["features"]:
        row = feature["attributes"]
        *place_list, precinct_num = row["jurisdictionname"].split()
        place_str = " ".join(place_list)
        row_dict = {
            "id": f"madison-{place_str.replace(' ', '-')}--{precinct_num}",
            "authority": "madison",
            "place": place_str,
            "ward": "",
            "precinct": row["jurisdictionname"],
            "ballots": int(row["ballotscast"]),
            "registered": int(row["regvoters"]),
        }
        if "PRESIDENT AND" in row["contest"]:
            if "BIDEN" in row["candidate"].upper():
                row_dict["us-president-dem"] = int(row["numvotes"])
            elif "TRUMP" in row["candidate"].upper():
                row_dict["us-president-rep"] = int(row["numvotes"])
            else:
                continue
            row_dict["us-president-votes"] = results_dict.get(
                row["jurisdictionname"], {}
            ).get("us-president-votes", 0) + int(row["numvotes"])
        elif "AMENDMENT" in row["contest"]:
            if row["candidate"] == "Yes":
                row_dict["il-constitution-yes"] = int(row["numvotes"])
            elif row["candidate"] == "No":
                row_dict["il-constitution-no"] = int(row["numvotes"])
            else:
                continue
            row_dict["il-constitution-votes"] = results_dict.get(
                row["jurisdictionname"], {}
            ).get("il-constitution-votes", 0) + int(row["numvotes"])

        results_dict[row["jurisdictionname"]] = {
            **results_dict[row["jurisdictionname"]],
            **row_dict,
        }

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(list(results_dict.values()))
