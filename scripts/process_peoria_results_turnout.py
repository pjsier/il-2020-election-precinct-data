import csv
import re
import sys
from itertools import zip_longest

COLUMNS = [
    "precinct",
    "registered",
    "ballots",
]


def grouper(iterable, n, fillvalue=None):
    args = [iter(iterable)] * n
    return zip_longest(*args, fillvalue=fillvalue)


if __name__ == "__main__":
    rows = [
        r
        for r in csv.reader(sys.stdin)
        if re.match(r"[A-Z]{2}\d\d", r[0]) or re.match(r"^\d+$", r[2])
    ]
    row_groups = grouper(rows, 2)

    results = []

    for reg_row, ballots_row in row_groups:
        ballot_vals = [int(v.replace(",", "")) for v in ballots_row if v.strip()]
        results.append(
            {
                "precinct": reg_row[0],
                "registered": int(reg_row[1].replace(",", "")),
                "ballots": ballot_vals[0],
            }
        )
        if reg_row[4].strip():
            results.append(
                {
                    "precinct": reg_row[4],
                    "registered": int(reg_row[5].replace(",", "")),
                    "ballots": ballot_vals[1],
                }
            )

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
