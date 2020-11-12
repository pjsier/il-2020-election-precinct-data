import csv
import sys
from collections import defaultdict

from bs4 import BeautifulSoup


def get_key(contest, choice):
    if "constitution" in contest.lower():
        return (
            "il-constitution-yes" if "yes" in choice.lower() else "il-constitution-no"
        )  # noqa
    if "united states" in contest.lower() and "president" in contest.lower():
        pass
    return


# Assume detail results, combine totals from different kinds of votes, might work on
# version not split out by vote types
if __name__ == "__main__":
    soup = BeautifulSoup(sys.stdin, "lxml")

    # result_dict = defaultdict(lambda: dict(
    #     "authority": "", "place": "", "ward": "", "precinct": "", "registered": 0, "ballots": 0, "turnout": 0, "us-president-dem": 0, "us-president-rep"))
    result_dict = {}
    rows = []

    for contest in soup.find_all("Contest"):
        for choice in contest.find_all("Choice"):
            print(choice.attrs)

    writer = csv.DictWriter(
        sys.stdout,
        fieldnames=[
            "id",
            "authority",
            "place",
            "ward",
            "precinct",
            "registered",
            "ballots",
            # "turnout", TODO: Calculate turnout from ballots / registered
            "us-president-dem",
            "us-president-rep",
            "us-president-votes",
            "il-constitution-yes",
            "il-constitution-no",
            "il-constitution-votes",
        ],
    )
    writer.writeheader()
    writer.writerows(rows)
