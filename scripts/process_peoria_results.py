import csv
import sys
from collections import defaultdict

if __name__ == "__main__":
    rows = [r for r in csv.DictReader(sys.stdin)]

    results_dict = defaultdict(dict)

    for row in rows:
        row_dict = {
            "precinct": row["precinct"],
            "authority": "peoria",
            "place": "",
            "ward": "",
        }
        if "PARTY" in row:
            row_dict["us-president-votes"] = row["totalvotes"]
        if row.get("PARTY") == "Democratic":
            row_dict["us-president-dem"] = row["NUMVOTES"]
        if row.get("PARTY") == "Republican":
            row_dict["us-president-rep"] = row["NUMVOTES"]
        results_dict[row["precinct"]] = {**results_dict[row["precinct"]], **row_dict}

    results = list(results_dict.values())
    writer = csv.DictWriter(sys.stdout, fieldnames=list(results[0].keys()))
    writer.writeheader()
    writer.writerows(results)
