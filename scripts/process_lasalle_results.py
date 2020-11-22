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

    for row in rows:
        results.append(
            {
                "id": "",
                "authority": "lasalle",
                "place": "",
                "ward": "",
                "precinct": " ".join(row[0].split()[1:]),
                "registered": row[1],
                "ballots": row[2],
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
