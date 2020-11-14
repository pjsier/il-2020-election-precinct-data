import csv
import re
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
    "precinct_num",
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
    "Joseph R. Biden & Kamala D. Harris": "us-president-dem",
    "Donald J. Trump & Michael R. Pence": "us-president-rep",
    "YES": "il-constitution-yes",
    "NO": "il-constitution-no",
}


def get_precinct_info(precinct_str):
    ward = ""
    if " Ward" not in precinct_str:
        *township_list, precinct = precinct_str.split(" ")
    else:
        *township_list, _, ward, _, precinct = precinct_str.split(" ")
    township = " ".join([w for w in township_list if w not in ["Ward", "Precinct"]])
    precinct_id = "-".join([w for w in [ward, precinct] if w])
    return {
        "id": f"cook-{township.lower().replace(' ', '-')}-{ward}-{precinct}",
        "authority": "cook",
        "place": township,
        "ward": ward,
        "precinct": f"{township.upper()} {precinct_id}",
        "precinct_num": precinct,
    }


def process_table(table, election):
    candidates = [th.text.strip() for th in table.find_all("th")][3:-1]
    headers = ["registered", "ballots", f"{election}-votes"] + candidates
    rows = []
    for row in table.select("tr[align='right']")[:-1]:
        row_dict = {}
        row_values = []
        for idx, cell in enumerate(row.select("td")):
            if idx == 0:
                row_dict = get_precinct_info(cell.text.strip())
                continue
            else:
                row_values.append(int(re.sub(r"\D", "", cell.text)))
        row_values.insert(0, row_values.pop(-1))
        row_dict = {**row_dict, **dict(zip(headers, row_values))}
        for k, v in COLUMN_MAP.items():
            if k in row_dict:
                row_dict[v] = row_dict.pop(k)
        row_keys = list(row_dict.keys())
        for key in row_keys:
            if key not in COLUMNS:
                row_dict.pop(key)
        rows.append(row_dict)
    return rows


def process_res(res, election):
    soup = BeautifulSoup(res, "html.parser")
    rows = []
    for table in soup.select(".results-precinct-container table"):
        rows.extend(process_table(table, election))
    return rows


if __name__ == "__main__":
    results_dict = defaultdict(dict)

    president_rows = process_res(
        requests.get(
            "https://results1120.cookcountyclerkil.gov/Detail.aspx",
            params={"eid": "110320", "rid": "11", "vfor": "1", "twpftr": "0"},
        ).text,
        "us-president",
    )
    tax_rows = process_res(
        requests.get(
            "https://results1120.cookcountyclerkil.gov/Detail.aspx",
            params={"eid": "110320", "rid": "10", "vfor": "1", "twpftr": "0"},
        ).text,
        "il-constitution",
    )

    for row in president_rows + tax_rows:
        results_dict[row["id"]] = {**results_dict[row["id"]], **row}

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(list(results_dict.values()))
