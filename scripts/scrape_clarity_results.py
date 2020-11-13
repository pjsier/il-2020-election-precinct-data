import csv
import sys

from bs4 import BeautifulSoup


def get_id(values):
    return "-".join([v.lower().replace(" ", "-") for v in values])


def get_contest(contest):
    if "constitution" in contest.lower():
        return "il-constitution"
    if "united states" in contest.lower() and "president" in contest.lower():
        return "us-president"


def get_key(contest, choice):
    if contest == "il-constitution":
        vote = "yes" if "yes" in choice.attrs["text"].lower() else "no"
        return f"{contest}-{vote}"
    if contest == "us-president":
        if choice.attrs["party"] == "D":
            return f"{contest}-dem"
        if choice.attrs["party"] == "R":
            return f"{contest}-rep"


# Assume detail results, combine totals from different kinds of votes, might work on
# version not split out by vote types
if __name__ == "__main__":
    soup = BeautifulSoup(sys.stdin, "xml")

    result_dict = {}

    for precinct in soup.find("VoterTurnout").find_all("Precinct"):
        if "presidential" in precinct.attrs["name"].lower():
            continue
        *place_list, precinct_str = precinct.attrs["name"].split()
        place = " ".join([p for p in place_list if p.lower() != "pct"])
        result_dict[precinct.attrs["name"]] = {
            "id": get_id([sys.argv[1], place, "", precinct_str]),
            "authority": sys.argv[1],
            "place": place,
            "ward": "",
            "precinct": precinct_str,
            "registered": int(precinct.attrs["totalVoters"]),
            "ballots": int(precinct.attrs["ballotsCast"]),
            "us-president-dem": 0,
            "us-president-rep": 0,
            "us-president-votes": 0,
            "il-constitution-yes": 0,
            "il-constitution-no": 0,
            "il-constitution-votes": 0,
        }

    for contest in soup.find_all("Contest"):
        contest_val = get_contest(contest.attrs["text"])
        if not contest_val:
            continue
        for choice in contest.find_all("Choice"):
            choice_key = get_key(contest_val, choice)
            for precinct in choice.find_all("Precinct"):
                if "presidential" in precinct.attrs["name"].lower():
                    continue
                result_dict[precinct.attrs["name"]][f"{contest_val}-votes"] += int(
                    precinct.attrs["votes"]
                )
                if choice_key:
                    result_dict[precinct.attrs["name"]][choice_key] += int(
                        precinct.attrs["votes"]
                    )

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
            "us-president-dem",
            "us-president-rep",
            "us-president-votes",
            "il-constitution-yes",
            "il-constitution-no",
            "il-constitution-votes",
        ],
    )
    writer.writeheader()
    writer.writerows(list(result_dict.values()))
