import csv
import re
import sys

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
    html_data = sys.stdin.read()
    authority = sys.argv[1]
    text = re.sub(r"<.*?>", "", html_data)

    precinct_sections = [
        s.strip() for s in re.split(r"RUN DATE.*?\n", text) if s.strip()
    ]

    results = []

    IGNORE_LINE_STRS = ["REPORT-GROUP DETAIL", "OFFICIAL RESULTS", "RUN TIME"]

    for precinct_section in precinct_sections:
        precinct_split = [
            s
            for s in re.split(r"[\r\n]{3,6}", precinct_section)
            if not any(ignore_str in s for ignore_str in IGNORE_LINE_STRS)
        ]
        if len(precinct_split) == 0:
            continue
        precinct_line = precinct_split[0].split("\n")[0].strip()[2:]
        precinct_num, *precinct_parts = precinct_line.split()
        # TODO: Replace this
        if precinct_parts[0] in ["BROWN", "COMPROMISE", "SADORUS", "SCOTT"]:
            place = precinct_parts[0]
        else:
            place = " ".join([p for p in precinct_parts if not re.match(r"\d+", p)])

        place = place.replace(".", "")
        precinct = f"{place} {precinct_num}"
        precinct_dict = {
            "id": f"{authority}-{place.lower().replace(' ', '-')}--{precinct_num}",
            "authority": authority,
            "place": place,
            "ward": "",
            "precinct": precinct,
        }

        for line in precinct_split[0].split("\n"):
            if "REGISTERED VOTERS - TOTAL" in line:
                # Total registered voters will be the first number in the row
                precinct_dict["registered"] = int(
                    re.search(r"[\d,]+", line).group().replace(",", "")
                )
            if "BALLOTS CAST - TOTAL" in line:
                # Total ballots will be the first number in the row
                precinct_dict["ballots"] = int(
                    re.search(r"[\d,]+", line).group().replace(",", "")
                )

        for contest in precinct_split[1:]:
            contest_lines = contest.split("\n")
            contest_name = contest_lines[0].strip()
            if not any([p in contest_name for p in ["PRESIDENT AND", "CONSTITUTION"]]):
                continue
            president_votes = 0
            constitution_votes = 0
            for line in contest_lines[1:]:
                if "VOTE FOR" in line:
                    continue
                if "BIDEN" in line:
                    precinct_dict["us-president-dem"] = int(
                        re.search(r"[\d,]+", line).group().replace(",", "")
                    )
                    president_votes += precinct_dict["us-president-dem"]
                elif "TRUMP" in line:
                    precinct_dict["us-president-rep"] = int(
                        re.search(r"[\d,]+", line).group().replace(",", "")
                    )
                    president_votes += precinct_dict["us-president-rep"]
                # Get other results for president section
                # ignore "Under Votes", "Over Votes"
                elif "PRESIDENT AND" in contest_name and "Votes" not in line:
                    votes_match = re.search(r"[\d,]+", line)
                    if votes_match:
                        president_votes += int(votes_match.group().replace(",", ""))
                elif line.strip().startswith("YES"):
                    precinct_dict["il-constitution-yes"] = int(
                        re.search(r"[\d,]+", line).group().replace(",", "")
                    )
                    constitution_votes += precinct_dict["il-constitution-yes"]
                elif line.strip().startswith("NO"):
                    precinct_dict["il-constitution-no"] = int(
                        re.search(r"[\d,]+", line).group().replace(",", "")
                    )
                    constitution_votes += precinct_dict["il-constitution-no"]
                elif "Under Votes" in line:
                    # TODO: Also check "Total" instead?
                    votes = precinct_dict["ballots"] - int(
                        re.search(r"[\d,]+", line).group().replace(",", "")
                    )
                    if "PRESIDENT" in contest_name:
                        precinct_dict["us-president-votes"] = votes
                    elif "CONSTITUTION" in contest_name:
                        precinct_dict["il-constitution-votes"] = votes
            if (
                "il-constitution-yes" in precinct_dict
                and "il-constitution-votes" not in precinct_dict
            ):
                precinct_dict["il-constitution-votes"] = constitution_votes

            if (
                "us-president-dem" in precinct_dict
                and "us-president-votes" not in precinct_dict
            ):
                precinct_dict["us-president-votes"] = president_votes
        results.append(precinct_dict)

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
