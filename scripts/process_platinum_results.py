import csv
import sys
from collections import defaultdict

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
    reader = csv.DictReader(sys.stdin)
    results_dict = defaultdict(dict)

    for row in reader:
        if not any(
            [
                p in row["Race Name"].upper()
                for p in ["PRESIDENT AND VICE", "IL CONSTITUTIONAL AMENDMENT"]
            ]
        ):
            continue
        # TODO: Handle multiple words without precinct num
        *township_list, precinct_num = row["Precinct Name"].split()
        township_str = " ".join(township_list)
        row_dict = {
            "id": f"{sys.argv[1]}-{township_str.lower().replace(' ', '-')}--{precinct_num}",  # noqa
            "authority": sys.argv[1],
            "place": township_str,
            "ward": "",
            "precinct": row["Precinct Name"],
            "registered": row["Registered Voters"],
            "ballots": row["Total Ballots Cast"],
        }

        if "PRESIDENT AND VICE" in row["Race Name"].upper():
            if "BIDEN" in row["Name"].upper():
                row_dict["us-president-dem"] = int(row["Votes"])
            elif "TRUMP" in row["Name"].upper():
                row_dict["us-president-rep"] = int(row["Votes"])
            # Increment or set total if not exists
            row_dict["us-president-votes"] = results_dict.get(
                row["Precinct Name"], {}
            ).get("us-president-votes", 0) + int(row["Votes"])
        elif "Constitution" in row["Race Name"]:
            if "YES" in row["Name"].upper():
                row_dict["il-constitution-yes"] = int(row["Votes"])
            elif "NO" in row["Name"].upper():
                row_dict["il-constitution-no"] = int(row["Votes"])
            row_dict["il-constitution-votes"] = results_dict.get(
                row["Precinct Name"], {}
            ).get("il-constitution-votes", 0) + int(row["Votes"])
        results_dict[row["Precinct Name"]] = {
            **results_dict[row["Precinct Name"]],
            **row_dict,
        }

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(list(results_dict.values()))
