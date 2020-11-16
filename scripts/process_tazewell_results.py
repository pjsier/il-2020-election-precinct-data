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
    rows = [r for r in csv.reader(sys.stdin)]
    results = []

    for row in rows[1:]:
        if row[0] in ["PRESIDENTIAL BALLOT", "Total"]:
            continue
        results.append(
            {
                "id": "",
                "authority": "tazewell",
                "place": "",
                "ward": "",
                "precinct": row[0],
                "registered": int(row[1]),
                "ballots": int(row[2]),
                "us-president-dem": int(row[10].split()[0]),
                "us-president-rep": int(row[9].split()[0]),
                "us-president-votes": int(row[8]),
                "il-constitution-yes": int(row[4]),
                "il-constitution-no": int(row[5]),
                "il-constitution-votes": int(row[3]),
            }
        )

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
