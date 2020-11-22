# Illinois 2020 General Election Precinct Data

## Prerequisites

Make, Python, `jq`, `mapshaper`, `xsv`

## Methodology

- Prioritize scraping from ArcGIS servers or downloading from open data portals
- If unavailable, check the [PDF precinct maps](https://www.elections.il.gov/precinctmaps/) submitted to the [Illinois State Board of Elections](https://www.elections.il.gov/) to see if they match [2016 voting precinct boundaries](https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/NH5S2I/IJPOUH&version=46.0)
- If matching precincts for an election authority are still unavailable, the precincts are obtained through a FOIA request
