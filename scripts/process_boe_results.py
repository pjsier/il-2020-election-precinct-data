import csv
import sys
from collections import defaultdict

PRESIDENT = "PRESIDENT AND VICE PRESIDENT"
TAX_AMENDMENT = "For the proposed amendment of Section 3 of Article IX of the Illinois Constitution."  # noqa
SENATOR = "UNITED STATES SENATOR"

IGNORE_CANDIDATES = ["Over Votes", "Under Votes", "Blank Ballots"]
CONTESTS = [PRESIDENT, TAX_AMENDMENT, SENATOR]

if __name__ == "__main__":
    precinct_dict = defaultdict(list)

    for row in csv.DictReader(sys.stdin):
        if not row["PrecinctName"].strip():
            continue
        precinct_dict[f"{row['JurisName']}|{row['PrecinctName']}"].append(row)

    results = []
    for precinct_key, precinct_rows in precinct_dict.items():
        authority_str, precinct = precinct_key.split("|")
        authority = authority_str.lower().replace(".", "").replace(" ", "-")
        if "daviess" in authority:
            authority = "jo-daviess"
        if "chicago" in authority:
            authority = "city-of-chicago"
        if "bloomington" in authority:
            authority = "city-of-bloomington"
        if "danville" in authority:
            authority = "city-of-danville"
        if "louis" in authority:
            authority = "city-of-east-st-louis"
        if "galesburg" in authority:
            authority = "city-of-galesburg"
        if "rockford" in authority:
            authority = "city-of-rockford"

        registered = int(precinct_rows[0]["Registration"])
        # Just using President as a placeholder so that we're only combining all votes
        # including under, over, and blank (might need to change)
        ballots = sum(
            [
                int(r["VoteCount"])
                for r in precinct_rows
                if r["ContestName"] == PRESIDENT
            ]
        )

        president_rows = [
            r
            for r in precinct_rows
            if r["ContestName"] == PRESIDENT
            and r["CandidateName"] not in IGNORE_CANDIDATES
        ]
        president_total = sum([int(r["VoteCount"]) for r in president_rows])
        president_dem = sum(
            [
                int(r["VoteCount"])
                for r in president_rows
                if "BIDEN" in r["CandidateName"].upper()
            ]
        )
        president_rep = sum(
            [
                int(r["VoteCount"])
                for r in president_rows
                if "TRUMP" in r["CandidateName"].upper()
            ]
        )

        constitution_rows = [
            r
            for r in precinct_rows
            if r["ContestName"] == TAX_AMENDMENT
            and r["CandidateName"] not in IGNORE_CANDIDATES
        ]
        constitution_total = sum([int(r["VoteCount"]) for r in constitution_rows])
        constitution_yes = sum(
            [
                int(r["VoteCount"])
                for r in constitution_rows
                if r["CandidateName"] == "YES"
            ]
        )
        constitution_no = sum(
            [
                int(r["VoteCount"])
                for r in constitution_rows
                if r["CandidateName"] == "NO"
            ]
        )

        senate_rows = [
            r
            for r in precinct_rows
            if r["ContestName"] == SENATOR
            and r["CandidateName"] not in IGNORE_CANDIDATES
        ]
        senate_total = sum([int(r["VoteCount"]) for r in senate_rows])
        senate_dem = sum(
            [
                int(r["VoteCount"])
                for r in senate_rows
                if "DURBIN" in r["CandidateName"].upper()
            ]
        )
        senate_rep = sum(
            [
                int(r["VoteCount"])
                for r in senate_rows
                if "CURRAN" in r["CandidateName"].upper()
            ]
        )
        senate_wil = sum(
            [
                int(r["VoteCount"])
                for r in senate_rows
                if "WILSON" in r["CandidateName"].upper()
            ]
        )

        results.append(
            {
                "authority": authority,
                "precinct": precinct,
                "registered": registered,
                "ballots": ballots,
                "us-president-dem": president_dem,
                "us-president-rep": president_rep,
                "us-president-votes": president_total,
                "il-constitution-yes": constitution_yes,
                "il-constitution-no": constitution_no,
                "il-constitution-votes": constitution_total,
                "us-senate-dem": senate_dem,
                "us-senate-rep": senate_rep,
                "us-senate-wil": senate_wil,
                "us-senate-votes": senate_total,
            }
        )

    writer = csv.DictWriter(
        sys.stdout,
        fieldnames=[
            "authority",
            "precinct",
            "registered",
            "ballots",
            "us-president-dem",
            "us-president-rep",
            "us-president-votes",
            "il-constitution-yes",
            "il-constitution-no",
            "il-constitution-votes",
            "us-senate-dem",
            "us-senate-rep",
            "us-senate-wil",
            "us-senate-votes",
        ],
    )

    writer.writeheader()
    writer.writerows(results)
