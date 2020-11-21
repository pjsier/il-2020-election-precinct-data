import sys

import requests
from bs4 import BeautifulSoup
from requests.compat import urljoin

if __name__ == "__main__":
    res = requests.get(
        "https://www.oglecounty.org/departments/county_clerk/election_night_results.php"
    )

    soup = BeautifulSoup(res.text, "html.parser")

    results_table = soup.select("table")[0]
    results = []
    for row in results_table.select("tr")[1:]:
        for results_link in row.select("a"):
            result_res = requests.get(
                urljoin("https://www.oglecounty.org", results_link.attrs["href"])
            )
            results.append(result_res.text)

    sys.stdout.write("\n\n\n".join(results))
