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
    rows = [row for row in csv.reader(sys.stdin)]

    results = []
    for row in rows:
        precinct = re.sub(r"\s+", " ", row[0]).strip()
        if "ELECTIONS OFFICE" in precinct or "Total" in precinct:
            continue
        results.append(
            {
                "id": "",
                "authority": "lee",
                "place": "",
                "ward": "",
                "precinct": re.sub(r"\s+", " ", row[0]).strip(),
                "registered": int(row[1]),
                "ballots": int(row[2]),
                "us-president-dem": int(row[9]),
                "us-president-rep": int(row[10]),
                "us-president-votes": int(row[8]),
                "il-constitution-yes": int(row[4]),
                "il-constitution-no": int(row[5]),
                "il-constitution-votes": int(row[3]),
            }
        )

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
