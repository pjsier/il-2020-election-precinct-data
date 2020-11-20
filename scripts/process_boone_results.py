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
    rows = [row for row in csv.reader(sys.stdin)]

    results = []
    for row in rows:
        r = []
        for v in row:
            if v.isdigit():
                r.append(int(v))
            elif v == "-":
                r.append(0)
            else:
                r.append(v)
        results.append(
            {
                "id": "",
                "authority": "boone",
                "place": "",
                "ward": "",
                "precinct": row[0],
                "registered": r[2],
                "ballots": r[3] + r[9] + r[15] + r[21],
                "us-president-dem": r[30] + r[35] + r[40] + r[45],
                "us-president-rep": r[29] + r[34] + r[39] + r[44],
                "us-president-votes": r[28] + r[33] + r[38] + r[43],
                "il-constitution-yes": r[5] + r[11] + r[17] + r[23],
                "il-constitution-no": r[6] + r[12] + r[18] + r[24],
                "il-constitution-votes": r[4] + r[10] + r[16] + r[22],
            }
        )

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
