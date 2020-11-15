import csv
import sys

import requests
from bs4 import BeautifulSoup

if __name__ == "__main__":
    res = requests.get(sys.argv[1])
    soup = BeautifulSoup(res.text, "html.parser")

    rows = []
    for row in soup.select(".tabledisplay .row:not(.header)"):
        precinct_cell, registered_cell = row.find_all("div", recursive=False)[:2]
        if not registered_cell.text.strip():
            continue
        rows.append(
            {
                "precinct": precinct_cell.text.strip(),
                "registered": int(registered_cell.text.replace(",", "").strip()),
            }
        )

    writer = csv.DictWriter(sys.stdout, fieldnames=["precinct", "registered"])
    writer.writeheader()
    writer.writerows(rows)
