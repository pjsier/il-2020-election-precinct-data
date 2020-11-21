import csv
import sys

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
    results = []

    IGNORE_STRS = ["ELECTIONS OFFICE", "Total", "Jurisdiction"]

    for row in csv.reader(sys.stdin):
        if any(s in row[0] for s in IGNORE_STRS):
            continue
        precinct = row[0]
        if precinct.startswith("SO "):
            precinct = " ".join(["SOUTH"] + precinct.split()[1:])
        results.append(
            {
                "id": "",
                "authority": "rock-island",
                "place": "",
                "ward": "",
                "precinct": precinct,
                "registered": int(row[1]),
                "ballots": int(row[2]),
                "us-president-dem": int(row[7]),
                "us-president-rep": int(row[6]),
                "us-president-votes": sum([int(v) for v in row[6:]]),
                "il-constitution-yes": int(row[3]),
                "il-constitution-no": int(row[4]),
                "il-constitution-votes": int(row[3]) + int(row[4]),
            }
        )

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
