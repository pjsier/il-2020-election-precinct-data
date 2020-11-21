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
        if "PRESIDENTIAL" in row[0]:
            continue
        precinct = row[0]
        if precinct == "LE ROY":
            precinct = "LEROY 1"
        elif precinct in ["MANCHESTER", "SPRING"]:
            precinct = f"{precinct} 1"
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
                "precinct": precinct,
                "registered": r[2],
                "ballots": r[3] + r[14] + r[25] + r[36],
                "us-president-dem": r[51] + r[58] + r[65] + r[72],
                "us-president-rep": r[49] + r[56] + r[63] + r[70],
                "us-president-votes": r[48] + r[55] + r[62] + r[69],
                "il-constitution-yes": r[8] + r[19] + r[30] + r[41],
                "il-constitution-no": r[10] + r[21] + r[32] + r[43],
                "il-constitution-votes": r[7] + r[18] + r[29] + r[40],
            }
        )

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
