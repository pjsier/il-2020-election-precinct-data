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
    text = re.sub(r"<.*?>", "", html_data)

    precinct_sections = [
        s.strip() for s in text.split("PREC REPORT-GROUP DETAIL") if s.strip()
    ]

    results = []

    for precinct_section in precinct_sections:
        precinct_split = re.split(r"[\r\n]{3,6}", precinct_section)[1:]
        precinct_line = precinct_split[0].split("\n")[0].strip()[2:]
        precinct_num, *precinct_parts = precinct_line.split()
        if precinct_parts[0] in ["BROWN", "COMPROMISE", "SADORUS", "SCOTT"]:
            place = precinct_parts[0]
        else:
            place = " ".join([p for p in precinct_parts if not re.match(r"\d+", p)])

        place = place.replace(".", "")
        precinct = f"{place} {precinct_num}"
        precinct_dict = {
            "id": f"champaign-{place.lower().replace(' ', '-')}--{precinct_num}",
            "authority": "champaign",
            "place": place,
            "ward": "",
            "precinct": precinct,
            # TODO: Registered voters not currently supplied
            "registered": 0,
        }

        for line in precinct_split[0].split("\n"):
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
            for line in contest_lines[1:]:
                if "BIDEN" in line:
                    precinct_dict["us-president-dem"] = int(
                        re.search(r"[\d,]+", line).group().replace(",", "")
                    )
                elif "TRUMP" in line:
                    precinct_dict["us-president-rep"] = int(
                        re.search(r"[\d,]+", line).group().replace(",", "")
                    )
                elif line.strip().startswith("YES"):
                    precinct_dict["il-constitution-yes"] = int(
                        re.search(r"[\d,]+", line).group().replace(",", "")
                    )
                elif line.strip().startswith("NO"):
                    precinct_dict["il-constitution-no"] = int(
                        re.search(r"[\d,]+", line).group().replace(",", "")
                    )
                elif "Under Votes" in line:
                    votes = precinct_dict["ballots"] - int(
                        re.search(r"[\d,]+", line).group().replace(",", "")
                    )
                    if "PRESIDENT" in contest_name:
                        precinct_dict["us-president-votes"] = votes
                    elif "CONSTITUTION" in contest_name:
                        precinct_dict["il-constitution-votes"] = votes
        results.append(precinct_dict)

    writer = csv.DictWriter(sys.stdout, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(results)
