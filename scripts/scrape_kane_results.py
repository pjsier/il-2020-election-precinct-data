import csv
import sys

import requests
from bs4 import BeautifulSoup
from requests.compat import urljoin

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


def parse_table(table):
    total_votes = 0
    result_dict = {}
    for choice in table.find_all("tr", recursive=False):
        choice_name, choice_votes = choice.find_all("td", recursive=False)[1:3]
        choice_text = choice_name.text.strip()
        choice_votes = int(choice_votes.text.strip())
        total_votes += choice_votes
        if "Biden" in choice_text:
            result_dict["us-president-dem"] = choice_votes
        elif "Trump" in choice_text:
            result_dict["us-president-rep"] = choice_votes
        elif choice_text == "Yes":
            result_dict["il-constitution-yes"] = choice_votes
        elif choice_text == "No":
            result_dict["il-constitution-no"] = choice_votes
    if "us-president-dem" in result_dict:
        result_dict["us-president-votes"] = total_votes
    else:
        result_dict["il-constitution-votes"] = total_votes
    return result_dict


def process_precinct(url, precinct, registered, ballots):
    res = requests.get(url)
    soup = BeautifulSoup(res.text, "html.parser")
    choice_tables = soup.select("table.choice")
    # Remove extra zero padding to match map results
    # TODO: Can re add by splitting in mapshaper if needed for official
    precinct_str = precinct.replace("00", "")
    return {
        "id": f"kane---{precinct_str}",
        "authority": "kane",
        "place": "",
        "ward": "",
        "precinct": precinct_str,
        "registered": registered,
        "ballots": ballots,
        **parse_table(choice_tables[1]),
        **parse_table(choice_tables[3]),
    }


if __name__ == "__main__":
    res = requests.get("http://electionresults.countyofkane.org/Precincts.aspx?Id=23")
    soup = BeautifulSoup(res.text, "html.parser")

    results = []
    for precinct_row in soup.select("tr:not(.totals)")[2:]:
        precinct_link = precinct_row.find("a")
        registered, ballots = precinct_row.find_all("td")[1:3]
        results.append(
            process_precinct(
                urljoin(res.url, precinct_link.attrs["href"]),
                precinct_link.text.strip(),
                int(registered.text.strip()),
                int(ballots.text.strip()),
            )
        )

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
