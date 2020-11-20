import csv
import re
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
    president_res = requests.get(
        "https://www.jodaviess.org/vertical/sites/%7B7C77C92D-D4A3-4866-8D3D-FE560FE5CFC8%7D/uploads/COPY_1_President_Vice_President-alternate.htm"  # noqa
    )
    constitution_res = requests.get(
        "https://www.jodaviess.org/vertical/sites/%7B7C77C92D-D4A3-4866-8D3D-FE560FE5CFC8%7D/uploads/COPY_Constitutional_Amendment-alternate.htm"  # noqa
    )

    president_soup = BeautifulSoup(president_res.text, "html.parser")
    constitution_soup = BeautifulSoup(constitution_res.text, "html.parser")

    precinct_groups = zip(
        president_soup.select("tr")[5:-2], constitution_soup.select("tr")[5:-2]
    )

    results = []

    for president_row, constitution_row in precinct_groups:
        precinct_str, *pres_values = [
            c.text.strip() for c in president_row.select("td")
        ]
        precinct = re.sub(r"\s+", " ", precinct_str).strip()
        if precinct == "Total":
            continue
        early_yes, day_yes, early_no, day_no = [
            int(re.sub(r"\D", "", c.text.strip()))
            for c in constitution_row.select("td")[1:]
        ]
        dem_early, dem_day, rep_early, rep_day, *other_votes = [
            int(re.sub(r"\D", "", v)) for v in pres_values
        ]
        total_pres = sum([dem_early, dem_day, rep_early, rep_day] + other_votes)
        # TODO: Registered, ballots not available
        results.append(
            {
                "id": f"jo-daviess---{precinct.lower().replace(' ', '-')}",
                "authority": "jo-daviess",
                "place": "",
                "ward": "",
                "precinct": precinct,
                "registered": 0,
                "ballots": 0,
                "us-president-dem": dem_early + dem_day,
                "us-president-rep": rep_early + rep_day,
                "us-president-votes": total_pres,
                "il-constitution-yes": early_yes + day_yes,
                "il-constitution-no": early_no + day_no,
                "il-constitution-votes": early_yes + day_yes + early_no + day_no,
            }
        )

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
