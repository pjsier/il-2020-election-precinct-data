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

    rows = [r for r in csv.reader(sys.stdin)]
    results = []

    for row in rows[1:]:
        if row[0] in ["PRESIDENTIAL BALLOT", "Total"]:
            continue
        precinct = row[0].strip()
        if authority == "tazewell":
            precinct_split = precinct.split()
            if len(precinct_split) == 1 or not re.search(r"\d", row[0]):
                precinct = f"{row[0]} 01"
            else:
                *precinct_name_split, precinct_num = precinct_split
                precinct_name = " ".join(precinct_name_split)
                precinct_name = precinct_name.replace("LT M", "LITTLE M")
                precinct = f"{precinct_name} {precinct_num.zfill(2)}"
        elif authority == "christian":
            precinct = precinct.replace("#", "").replace(" 0", " ")
            if precinct in [
                "ASSUMPTION",
                "BUCKHART",
                "MT AUBURN",
                "RICKS",
                "STONINGTON",
            ]:
                precinct = f"{precinct} 1"
        elif authority == "macoupin":
            if precinct == "HILYARD":
                precinct = "HILLYARD"
        results.append(
            {
                "id": "",
                "authority": authority,
                "place": "",
                "ward": "",
                "precinct": precinct,
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
