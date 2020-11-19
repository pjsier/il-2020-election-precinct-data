# Illinois 2020 Elections Precinct Data

## TODO

- Pull raw text results
  - https://github.com/PalmBeachPost/election-results-parser
  - https://github.com/newsdev/elex
- Scrapers for
  - platinumelectionresults.com
  - http://dekalb.il.electionconsole.com/precinct.php?e=2020%20General
- See if can pull precinct results from pollresults.net

## Prerequisites

Make, Python, `jq`, `mapshaper`, `xsv`

## Methodology

- Prioritize scraping from ArcGIS servers or downloading from open data portals
- If unavailable, check the [PDF precinct maps](https://www.elections.il.gov/precinctmaps/) submitted to the [Illinois State Board of Elections](https://www.elections.il.gov/) to see if they match [2016 voting precinct boundaries](https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/NH5S2I/IJPOUH&version=46.0)
- If matching precincts for an election authority are still unavailable, the precincts are obtained through a FOIA request
