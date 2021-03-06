# Illinois 2020 General Election Precinct Data

Election results by precinct and precinct boundaries for the Illinois 2020 general election. Results include races for US President, US Senate, and the proposed constitutional amendment. Precinct boundary GeoJSON files without results are in [`data/precincts/`](./data/precincts/), CSV files of results are in [`data/results/`](./data/results/), and GeoJSON files of boundaries joined to results are in [`output/`](./output/).

## Methodology

Precinct boundaries come from election authorities when a source is available. Sources include open data portals, ArcGIS servers scraped with with [`pyesridump`](https://github.com/openaddresses/pyesridump), and other locations loaded with custom scripts. In a few cases boundaries come from FOIA requests included in this repo. Otherwise boundaries are 2016 precincts from the [Voting and Election Science Team on the Harvard Dataverse](https://doi.org/10.7910/DVN/NH5S2I/IJPOUH).

Precinct boundaries are checked against [precinct maps as PDFs or images maintained by the Illinois State Board of Elections](https://www.elections.il.gov/precinctmaps/), and in some cases when 2016 precincts have been consolidated and aren't otherwise available they're modified here.

### Known Data Issues

- Registration and total ballot counts aren't currently accurate
- Jackson county precincts Carbondale 21, 22, 24, and 25 are manually edited based off of approved changes
- Winnebago county precincts Cherry Valley 1, 4, 9 and 12 as well as Harlem 4, 16 18 and 19 are manually edited based off of maps online

## Attribution

Voting and Election Science Team, 2018, "il_2016.zip", 2016 Precinct-Level Election Results, https://doi.org/10.7910/DVN/NH5S2I/IJPOUH, Harvard Dataverse, V46

## Setup

You'll need GNU Make, Python, [`jq`](https://stedolan.github.io/jq/), [`mapshaper`](https://github.com/mbloch/mapshaper/), and [`xsv`](https://github.com/burntsushi/xsv) installed.

To install Python dependencies and rebuild data locally, run:

```shell
make install
```
