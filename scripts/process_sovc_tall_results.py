import csv
import re
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
    authority = sys.argv[1]
    results = []

    IGNORE_STRS = ["ELECTIONS OFFICE", "Total", "Jurisdiction"]

    for row in csv.reader(sys.stdin):
        if any(s in row[0] for s in IGNORE_STRS):
            continue
        precinct = row[0]
        if authority == "crawford":
            if precinct in ["MARTIN", "LICKING", "MONTGOMERY"]:
                precinct = f"{precinct} 1"
        if authority == "mcdonough":
            precinct = re.sub(r"\s+", " ", precinct).strip()
        results.append(
            {
                "id": "",
                "authority": authority,
                "place": "",
                "ward": "",
                "precinct": precinct,
                "registered": int(row[1]),
                "ballots": int(row[2]),
                "us-president-dem": int(row[8]),
                "us-president-rep": int(row[9]),
                "us-president-votes": int(row[7]),
                "il-constitution-yes": int(row[4]),
                "il-constitution-no": int(row[5]),
                "il-constitution-votes": int(row[3]),
            }
        )

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
