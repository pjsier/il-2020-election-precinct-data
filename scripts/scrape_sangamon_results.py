import csv
import sys

import requests

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
    turnout_res = requests.get(
        "https://results.enr.clarityelections.com//IL/Sangamon/106268/271709/json/status.json"  # noqa
    )
    contest_res = requests.get(
        "https://results.enr.clarityelections.com//IL/Sangamon/106268/271709/json/ALL.json"  # noqa
    )
    turnout_data = turnout_res.json()
    contest_data = contest_res.json()

    precinct_data = list(
        zip(
            turnout_data["P"],
            turnout_data["R"],
            turnout_data["B"],
            contest_data["Contests"][:-1],
        )
    )[:-1]

    results = []

    for precinct, registered, ballots, data in precinct_data:
        results.append(
            {
                "id": "",
                "authority": "sangamon",
                "place": "",
                "ward": "",
                "precinct": precinct,
                "registered": registered,
                "ballots": ballots,
                "us-president-dem": data["V"][1][0],
                "us-president-rep": data["V"][1][1],
                "us-president-votes": sum(data["V"][1]),
                "il-constitution-yes": data["V"][0][0],
                "il-constitution-no": data["V"][0][1],
                "il-constitution-votes": sum(data["V"][0]),
            }
        )

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
