import csv
import sys
from itertools import zip_longest

IGNORE_VALS = ["Voters", "Total", "PRESIDENTIAL"]


def grouper(iterable, n, fillvalue=None):
    args = [iter(iterable)] * n
    return zip_longest(*args, fillvalue=fillvalue)


if __name__ == "__main__":
    rows = [
        row for row in csv.reader(sys.stdin) if not any(v in row for v in IGNORE_VALS)
    ][1:]
    row_groups = grouper(
        [row for row in rows if not any(v in row for v in IGNORE_VALS)], 5,
    )

    results = []
    for row_group in row_groups:
        precinct_row, *data_rows = row_group
        row_lists = [row for row in data_rows if row]
        row_values = [
            precinct_row[0],
            *[item for row_list in row_lists for item in row_list],
        ]
        if len(results) > 0 and len(row_values) != len(results[-1]):
            break
        results.append(row_values)

    writer = csv.writer(sys.stdout)
    writer.writerows(results)
