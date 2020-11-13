import csv
import sys
from collections import defaultdict

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

COLUMN_MAP = {
    "REGISTERED VOTERS": "registered",
    "BALLOTS CAST": "ballots",
    "Joseph R. Biden & Kamala D. Harris": "us-president-dem",
    "Donald J. Trump & Michael R. Pence": "us-president-rep",
    "Yes": "il-constitution-yes",
    "No": "il-constitution-no",
}


def get_headers(html):
    headers = [v.text.strip() for v in html.find("table").find_all("b")]
    return [h for h in headers if "%" not in h]


def get_row_values(row, ward, headers, election):
    values = [v.text.strip() for v in row.find_all("td")]
    if len(values) == 0 or any(
        w in values[0].lower() for w in ["total", "precinct", "ward"]
    ):
        return
    vote_values = [int(v.replace(",", "")) for v in values[1:] if "%" not in v]

    vote_values_dict = dict(zip(headers, vote_values))
    row_dict = {
        "id": f"chicago-chicago-{ward}-{int(values[0])}",
        "authority": "chicago",
        "place": "chicago",
        "ward": ward,
        "precinct": int(values[0]),
    }
    for k, v in COLUMN_MAP.items():
        if k in vote_values_dict:
            row_dict[v] = vote_values_dict[k]
    if "Votes" in vote_values_dict:
        row_dict[f"{election}-votes"] = vote_values_dict["Votes"]

    return row_dict


def process_table(table, headers, election):
    ward = int(table.select_one("thead th b, tr td b").text.split()[-1])
    rows = []
    for row in table.find_all("tr"):
        row_values = get_row_values(row, ward, headers, election)
        if row_values:
            rows.append(row_values)
    return rows


def process_res(res, election):
    soup = BeautifulSoup(res, "html.parser")
    headers = get_headers(soup)
    rows = []
    for table in soup.find_all("table")[1:]:
        rows.extend(process_table(table, headers, election))
    return rows


if __name__ == "__main__":
    results_dict = defaultdict(dict)

    voter_rows = process_res(
        requests.post(
            "https://chicagoelections.gov/en/election-results-specifics.asp",
            data={"election": "251", "race": "", "ward": "", "precinct": ""},
        ).text,
        "",
    )
    president_rows = process_res(
        requests.post(
            "https://chicagoelections.gov/en/election-results-specifics.asp",
            data={"election": "251", "race": "11", "ward": "", "precinct": ""},
        ).text,
        "us-president",
    )
    tax_rows = process_res(
        requests.post(
            "https://chicagoelections.gov/en/election-results-specifics.asp",
            data={"election": "251", "race": "10", "ward": "", "precinct": ""},
        ).text,
        "il-constitution",
    )

    for row in voter_rows + president_rows + tax_rows:
        results_dict[row["id"]] = {**results_dict[row["id"]], **row}

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(list(results_dict.values()))
