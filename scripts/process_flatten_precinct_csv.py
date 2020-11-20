import csv
import sys
from itertools import zip_longest

IGNORE_VALS = ["Voters", "Total"]


def grouper(iterable, n, fillvalue=None):
    args = [iter(iterable)] * n
    return zip_longest(*args, fillvalue=fillvalue)


if __name__ == "__main__":
    row_groups = grouper(
        [
            row
            for row in csv.reader(sys.stdin)
            if not any(v in row for v in IGNORE_VALS)
        ],
        5,
    )

    results = []
    for row_group in row_groups:
        precinct_row, *data_rows = row_group
        results.append(
            [precinct_row[0], *[item for row_list in data_rows for item in row_list]]
        )

    writer = csv.writer(sys.stdout)
    writer.writerows(results)
