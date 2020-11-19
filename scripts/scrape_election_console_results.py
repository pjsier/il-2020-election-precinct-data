import csv
import sys

import requests
from bs4 import BeautifulSoup

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
    authority, results_url = sys.argv[1:3]
    res = requests.get(results_url)
    soup = BeautifulSoup(res.text, "html.parser")

    results = []

    for precinct_row in soup.select("table[cellspacing] tr[id] table[cellspacing] tr"):
        precinct_name_cell, _, voters_cell, ballots_cell = precinct_row.select("td")[1:]
        precinct_res = requests.get(precinct_name_cell.select("a")[0].attrs["href"])
        precinct_soup = BeautifulSoup(precinct_res.text, "html.parser")

        precinct_name = precinct_name_cell.text.strip()
        precinct_dict = {
            "id": f"{authority}---{precinct_name.replace(' ', '-')}",
            "authority": "",
            "place": "",
            "ward": "",
            "precinct": precinct_name,
            "registered": int(voters_cell.text.strip()),
            "ballots": int(ballots_cell.text.strip()),
            "us-president-votes": 0,
            "il-constitution-votes": 0,
        }

        contest_tables = precinct_soup.select(".report-table-name + table")[:4]
        for contest_table in contest_tables:
            for contest_row in contest_table.select("tr")[1:]:
                choice, votes = [c.text for c in contest_row.select("td")][:2]
                votes_int = int(votes)
                if "BIDEN" in choice.upper():
                    choice_key = "us-president-dem"
                elif "TRUMP" in choice.upper():
                    choice_key = "us-president-rep"
                elif "YES (" in choice.upper():
                    choice_key = "il-constitution-yes"
                elif "NO (" in choice.upper():
                    choice_key = "il-constitution-no"
                # If already pulled skip (for duplicate tables)
                if choice_key in precinct_dict:
                    continue
                *contest_key_parts, contest_choice_key = choice_key.split("-")
                contest_key = "-".join(contest_key_parts)
                precinct_dict[f"{contest_key}-votes"] += votes_int
                precinct_dict[choice_key] = votes_int

        results.append(precinct_dict)

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
