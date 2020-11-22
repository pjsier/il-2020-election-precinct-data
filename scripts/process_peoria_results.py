import csv
import re
import sys

COLUMNS = [
    "id",
    "authority",
    "place",
    "ward",
    "precinct",
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

    for idx, row in enumerate(rows):
        if row[0].startswith("Precinct ") and rows[idx + 1][0].startswith(
            "CONSTITUTION"
        ):
            results.append(
                {
                    "id": "",
                    "authority": "peoria",
                    "place": "",
                    "ward": "",
                    "precinct": re.search(r"[A-Z]{2}\d\d", row[0]).group(),
                    "us-president-dem": int(rows[idx + 8][3].replace(",", "")),
                    "us-president-rep": int(rows[idx + 7][3].replace(",", "")),
                    "us-president-votes": int(rows[idx + 22][3].replace(",", "")),
                    "il-constitution-yes": int(rows[idx + 2][3].replace(",", "")),
                    "il-constitution-no": int(rows[idx + 3][3].replace(",", "")),
                    "il-constitution-votes": int(rows[idx + 4][3].replace(",", "")),
                }
            )

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
