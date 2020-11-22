PRECINCT_FILES := $(shell cat input/jurisdictions.txt | xargs -I {} echo "data/precincts/{}.geojson")

all: $(PRECINCT_FILES)

.PHONY: clean
clean:
	rm -f output/*.geojson data/precincts/*.geojson data/results-unofficial/*.csv input/precincts/*.* input/results-unofficial/*.*

.PHONY: install
install:
	pipenv sync --dev

output/%.geojson: data/precincts/%.geojson data/results-unofficial/%.csv
	mapshaper -i $< -join $(filter-out $<,$^) keys=precinct,precinct field-types=precinct:str -o $@

data/precincts/adams.geojson:
	pipenv run esri2geojson http://www.adamscountyarcserver.com/adamscountyarcserver/rest/services/AdamsCoBaseMapFG_2018/MapServer/43 - | \
	mapshaper -i - -rename-fields precinct_name=Precinct -rename-fields precinct=pwd -o $@

data/precincts/alexander.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "003"' -o $@

data/precincts/bond.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "005"' -o $@

data/precincts/boone.geojson:
	pipenv run esri2geojson https://maps.boonecountyil.org/arcgis/rest/services/Clerk_and_Recorder/Voting_Polling_Places/MapServer/1 - | \
	mapshaper -i - \
	-rename-fields precinct_num=Precinct \
	-each 'precinct = TWP_PRECIN.toUpperCase()' \
	-dissolve2 precinct \
	-o $@

data/precincts/brown.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "009"' \
	-each 'precinct = precinct.split(" ").map(function (word) { return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase(); }).join(" ")' \
	-o $@

data/precincts/bureau.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "011"' -o $@

data/precincts/calhoun.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "013"' -o $@

data/precincts/carroll.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "015"' -o $@

data/precincts/cass.geojson:
	pipenv run python scripts/pybeacondump.py 'https://beacon.schneidercorp.com/Application.aspx?AppID=55&LayerID=375&PageTypeID=1&PageID=916' 1751 - | \
	mapshaper -i - \
	-proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-90.16666666666667 +k=0.999941 +x_0=700000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 \
	-dissolve2 Precinct \
	-rename-fields precinct=Precinct \
	-o $@

data/precincts/champaign.geojson:
	pipenv run esri2geojson --proxy https://services.ccgisc.org/proxy/proxy.ashx? https://services.ccgisc.org/server/rest/services/CountyClerk/Precincts/MapServer/0 - | \
	mapshaper -i - -each 'precinct = TWPNAME.toUpperCase() + " " + PrecinctNum' -o $@

data/precincts/christian.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "021"' -o $@

data/precincts/clark.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "023"' -o $@

data/precincts/clay.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "025"' -o $@

data/precincts/clinton.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "027"' -o $@

data/precincts/coles.geojson:
	pipenv run python scripts/scrape_coles.py | \
	mapshaper -i - -proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-88.33333333333333 +k=0.999975 +x_0=300000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 -o $@

data/precincts/cook.geojson:
	pipenv run esri2geojson https://gis12.cookcountyil.gov/arcgis/rest/services/electionSrvcLite/MapServer/1 - | \
	mapshaper -i - \
	-filter-fields NAME,Num \
	-each 'precinct = NAME + " " + Num' \
	-o $@

data/precincts/crawford.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "033"' -o $@

data/precincts/cumberland.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "035"' -o $@

data/precincts/dekalb.geojson: input/precincts/Precinct_Area.shp
	mapshaper -i $< \
	-proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-88.33333333333333 +k=0.999975 +x_0=300000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 \
	-each 'township = Precinct_N.slice(0,2) === "CL" ? "Clinton" : Township' \
	-each 'township = Precinct_N.slice(0,2) === "CO" ? "Cortland" : township' \
	-each 'township = Precinct_N.slice(0,2) === "GE" ? "Genoa" : township' \
	-each 'township = Precinct_N.slice(0,2) === "SO" ? "Somonauk" : township' \
	-each 'precinct = township.toUpperCase() + " " + Precinct_N.split(" ").slice(-1)[0]' \
	-o $@

# TODO: Figure out where to put source, only derived?
input/precincts/Precinct_Area.shp: input/foia/Precinct_Area.zip
	unzip -u $< -d $(dir $@)

data/precincts/dewitt.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "039"' -o $@

data/precincts/douglas.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "041"' -o $@

data/precincts/dupage.geojson:
	pipenv run esri2geojson https://gis.dupageco.org/arcgis/rest/services/Elections/ElectionPrecincts/MapServer/0 - | \
	mapshaper -i - \
	-rename-fields precinct=PrecinctName \
	-each 'precinct = precinct.replace(Precinct.toString(), Precinct.toString().padStart(3, "0"))' \
	-o $@

data/precincts/edgar.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "045"' -o $@

data/precincts/edwards.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "047"' -o $@

data/precincts/effingham.geojson:
	pipenv run esri2geojson https://services.arcgis.com/vj0V9Lal6oiz0YXp/ArcGIS/rest/services/ElectoralDistricts/FeatureServer/1 $@

data/precincts/fayette.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "051"' \
	-each 'precinct = precinct.includes("AVENA") ? "AVENA 1" : precinct' \
	-each 'precinct = precinct.includes("OTEGO") ? "OTEGO 1" : precinct' \
	-each 'precinct = precinct.includes("RAMSEY") ? "RAMSEY 1" : precinct' \
	-each 'precinct = precinct.replace("SO H", "S H")' \
	-dissolve2 precinct \
	-o $@

data/precincts/ford.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "053"' -o $@

data/precincts/franklin.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "055"' \
	-each 'precinct = precinct.replace("CAVE 1", "CAVE")' \
	-o $@

data/precincts/fulton.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "057"' -o $@

data/precincts/gallatin.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "059"' -o $@

data/precincts/greene.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "061"' -o $@

data/precincts/grundy.geojson:
	pipenv run esri2geojson https://maps.grundyco.org/arcgis/rest/services/CountyClerk/PollingPlaces_SPIE_Public/FeatureServer/1 - | \
	mapshaper -i - -each 'precinct = NAME.toUpperCase()' -o $@

data/precincts/hamilton.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "065"' -o $@

data/precincts/hancock.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "067"' -o $@

data/precincts/hardin.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "069"' -o $@

data/precincts/henderson.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "071"' -o $@

data/precincts/henry.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "073"' \
	-each 'precinct = precinct.replace("COLONA 2", "COLONA 2 B")' \
	-o $@

data/precincts/iroquois.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/IroquoisIL/IroquoisIL_PAT_GIS/MapServer/8 $@

data/precincts/jackson.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "077"' -o $@

data/precincts/jasper.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "079"' -o $@

data/precincts/jefferson.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "081"' -o $@

data/precincts/jersey.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "083"' -o $@

data/precincts/jo-daviess.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "085"' -o $@

data/precincts/johnson.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "087"' -o $@

# TODO: 3 precincts prefixed AC don't have matching records
data/precincts/kane.geojson:
	pipenv run esri2geojson https://utility.arcgis.com/usrsvcs/servers/1db346a5fb5c4a5abfe52acfc97ad2a2/rest/services/Kane_Precincts/FeatureServer/0 --header Referer:'https://kanegis.maps.arcgis.com/apps/webappviewer/index.html' - | \
	mapshaper -i - -rename-fields precinct=NPrecinct -o $@

data/precincts/kankakee.geojson:
	pipenv run esri2geojson https://k3gis.com/arcgis/rest/services/BASE/Elected_Officials/MapServer/0 - | \
	mapshaper -i - -each 'precinct = name.toUpperCase()' -o $@

data/precincts/kendall.geojson: input/precincts/Kendall_County_Voting_Precinct.shp
	mapshaper -i $< \
	-proj wgs84 \
	-each 'precinct = (twp_name + " " + precinct_).replace(/-/gi, " ")' \
	-o $@

input/precincts/Kendall_County_Voting_Precinct.shp: input/precincts/kendall.zip
	unzip -u $< -d $(dir $@)

input/precincts/kendall.zip:
	wget -O $@ 'https://opendata.arcgis.com/datasets/bc2430d057cb487aa51273e4e8762c2e_0.zip?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D'

data/precincts/knox.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "095" && !precinct.includes("GALESBURG CITY")' -o $@

data/precincts/lake.geojson:
	pipenv run esri2geojson https://maps.lakecountyil.gov/arcgis/rest/services/GISMapping/WABPoliticalBoundaries/MapServer/5 - | \
	mapshaper -i - \
	-each 'precinct = PRECINCT.toString()' \
	-filter-fields precinct \
	-dissolve2 precinct \
	-o $@

data/precincts/lasalle.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "099"' \
	-each 'precinct = precinct.replace("LA SALLE", "LASALLE")' \
	-o $@

data/precincts/lawrence.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "101"' -o $@

data/precincts/lee.geojson:
	pipenv run esri2geojson https://gis.leecountyil.com/server/rest/services/Election/Election_Precincts/MapServer/0 - | \
	mapshaper -i - \
	-each 'precinct = LYR_NAME.toUpperCase()' \
	-filter 'precinct !== "ROCK RIVER"' \
	-o $@

data/precincts/livingston.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "105"' -o $@

data/precincts/logan.geojson:
	pipenv run esri2geojson https://www.centralilmaps.com/arcgis/rest/services/Logan/Logan_Flex_1/MapServer/40 $@

data/precincts/macon.geojson:
	pipenv run esri2geojson https://services1.arcgis.com/a3k0qIja5SolIRYR/ArcGIS/rest/services/ElectionGeography_public/FeatureServer/1 $@

data/precincts/macoupin.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/MacoupinIL/MacoupinIL_PAT_GIS/MapServer/4 - | \
	mapshaper -i - -rename-fields precinct=PRECINCT -o $@

data/precincts/madison.geojson:
	pipenv run esri2geojson https://services.arcgis.com/Z0kKj2K728ngqqrp/ArcGIS/rest/services/ElectionGeography_public/FeatureServer/1 - | \
	mapshaper -i - -rename-fields precinct=name -filter-fields precinct -o $@

data/precincts/marion.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "121"' \
	-each 'precinct = precinct.includes("CENTRALIA") ? "CENTRALIA " + precinct.split(" ").slice(-1)[0].padStart(2, "0") : precinct' \
	-o $@

data/precincts/marshall.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "123"' -o $@

data/precincts/mason.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "125"' -o $@

data/precincts/massac.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "127"' -o $@

data/precincts/mcdonough.geojson:
	pipenv run python scripts/scrape_mcdonough.py | \
	mapshaper -i - \
	-proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-90.16666666666667 +k=0.999941 +x_0=700000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 \
	-each 'precinct = Name.toUpperCase().replace("MACOMB", "MACOMB TWP").replace("MC ", "MACOMB CITY ")' \
	-o $@

data/precincts/mchenry.geojson:
	pipenv run esri2geojson https://www.mchenrycountygis.org/arcgis/rest/services/County_Board/Precincts/MapServer/0 - | \
	mapshaper -i - \
	-rename-fields precinct=Name10 \
	-each 'precinct = precinct.replace("ALDEN", "ALDEN 1").replace("DUNHAM", "DUNHAM 1").replace("RILEY", "RILEY 1")' \
	-o $@

data/precincts/mclean.geojson: input/precincts/mclean.geojson
	mapshaper -i $< -filter '!precinct.includes("City of Bloomington")' -o $@

input/precincts/mclean.geojson: input/precincts/Voting_Precincts.shp
	mapshaper -i $< -rename-fields precinct=NAME -o $@

input/precincts/Voting_Precincts.shp: input/precincts/mclean.zip
	unzip -u $< -d $(dir $@)

input/precincts/mclean.zip:
	wget -O $@ https://opendata.arcgis.com/datasets/bb22d15063da452587c82339cb7a3322_15.zip

data/precincts/menard.geojson:
	pipenv run python scripts/pybeacondump.py 'https://beacon.schneidercorp.com/Application.aspx?App=MenardCountyIL&PageType=Map' 25751 - | \
	mapshaper -i - \
	-proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-90.16666666666667 +k=0.999941 +x_0=700000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 \
	-dissolve2 Name \
	-rename-fields precinct=Name \
	-o $@

data/precincts/mercer.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "131"' -o $@

data/precincts/monroe.geojson:
	pipenv run esri2geojson https://services.arcgis.com/AZVIEb4WFZST2UYx/arcgis/rest/services/Voter_Precincts/FeatureServer/0 - | \
	mapshaper -i - \
	-each 'precinct = PRECINCT.toString()' \
	-o $@

data/precincts/montgomery.geojson:
	pipenv run python scripts/pybeacondump.py 'https://beacon.schneidercorp.com/Application.aspx?AppID=503&LayerID=7586&PageTypeID=1&PageID=3800' 7705 - | \
	mapshaper -i - \
	-proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-90.16666666666667 +k=0.999941 +x_0=700000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 \
	-dissolve2 NAME \
	-rename-fields precinct=NAME \
	-each 'precinct = precinct.trim()' \
	-o $@

data/precincts/morgan.geojson:
	wget -qO - 'https://morganmaps.maps.arcgis.com/sharing/rest/content/items/8d7a6a2f54fa4686b6cbcfc47c6fb4d1/data?f=json' | \
	jq '.operationalLayers[0].featureCollection.layers[0].featureSet' | \
	pipenv run arcgis2geojson | \
	mapshaper -i - -proj init=webmercator crs=wgs84 -o $@

data/precincts/moultrie.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "139"' -o $@

data/precincts/ogle.geojson:
	pipenv run python scripts/pybeacondump.py 'https://beacon.schneidercorp.com/Application.aspx?AppID=71&LayerID=592&PageTypeID=1&PageID=953' 5178 - | \
	mapshaper -i - \
	-proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-90.16666666666667 +k=0.999941 +x_0=700000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 \
	-dissolve2 precinct \
	-each 'precinct = precinct.toUpperCase().replace(".", "")' \
	-o $@

data/precincts/peoria.geojson:
	pipenv run esri2geojson https://services.arcgis.com/iPiPjILCMYxPZWTc/arcgis/rest/services/Voting_Precincts/FeatureServer/0 - | \
	mapshaper -i - -rename-fields precinct=PRECINCTID -o $@

data/precincts/perry.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "145"' -o $@

data/precincts/piatt.geojson:
	pipenv run esri2geojson --proxy https://services.ccgisc.org/proxy/proxy.ashx? https://services.ccgisc.org/server2/rest/services/Piatt_CountyClerk/Precincts/MapServer/0 $@

data/precincts/pike.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "149"' -o $@

data/precincts/pope.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "151"' -o $@

data/precincts/pulaski.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "153"' -o $@

data/precincts/putnam.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "155"' -o $@

data/precincts/randolph.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "157"' \
	-each 'precinct = precinct.replace(/-/gi, " ")' \
	-o $@

data/precincts/richland.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "159"' -o $@

data/precincts/rock-island.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "161"' -o $@

data/precincts/saline.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "165"' -o $@

data/precincts/sangamon.geojson:
	pipenv run esri2geojson https://services.arcgis.com/XqG0RpqsNfIBGGb2/ArcGIS/rest/services/ElectionPollingAndPrecincts/FeatureServer/1 - | \
	mapshaper -i - -rename-fields precinct=NAME -o $@

data/precincts/schuyler.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "169"' -o $@

data/precincts/scott.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "171"' -o $@

data/precincts/shelby.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "173"' -o $@

data/precincts/st-clair.geojson: input/precincts/st-clair.geojson
	mapshaper -i $< \
	-filter '!prec_name1.includes("East St")' \
	-rename-fields precinct=prec_name2 \
	-each 'precinct = precinct.replace("Ofallon", "O Fallon").replace("  ", " ")' \
	-o $@

input/precincts/st-clair.geojson:
	pipenv run esri2geojson https://publicmap01.co.st-clair.il.us/arcgis/rest/services/SCC_voting_district/MapServer/7 $@

data/precincts/stark.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "175"' \
	-each 'precinct = precinct.split(" ").slice(0, -1).join(" ")' \
	-o $@

data/precincts/stephenson.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "177"' -o $@

data/precincts/tazewell.geojson:
	pipenv run esri2geojson https://gis.tazewell.com/maps/rest/services/ElectionPoll/ElectionPollingPlaces/MapServer/1 - | \
	mapshaper -i - -each 'precinct = NAME.toUpperCase().replace("BOYTON", "BOYNTON").replace("DEERCREEK", "DEER CREEK")' -o $@

data/precincts/union.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "181"' \
	-each 'precinct = precinct.replace("UNION 1", "UNION")' \
	-o $@

data/precincts/vermilion.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/VermilionIL/VermilionIL_PAT_GIS/MapServer/12 - | \
	mapshaper -i - \
	-rename-fields precinct=PRECINCT_E \
	-filter '!precinct.includes("DANVILLE CITY")' \
	-each 'precinct = precinct.replace("CARROLL", "CARROLL 1").replace("VANCE", "VANCE 1").replace("JAMAICA", "JAMAICA 1").replace("LOVE", "LOVE 1").replace("MCKENDREE", "MCKENDREE 1")' \
	-o $@

data/precincts/wabash.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "185"' -o $@

data/precincts/warren.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "187"' -o $@

data/precincts/washington.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "189"' -o $@

data/precincts/wayne.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "191"' \
	-each 'precinct = precinct.replace(" TWP", "").replace("GROVER/", "").replace(" PCT", "").replace("MT ", "MT. ").replace("GOLDEN ", "GOLDEN")' \
	-o $@

data/precincts/white.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "193"' -o $@

data/precincts/whiteside.geojson:
	pipenv run esri2geojson https://services.arcgis.com/l0M0OC6J9QAHCiGx/ArcGIS/rest/services/ElectionGeography_public/FeatureServer/1 $@

data/precincts/will.geojson:
	pipenv run esri2geojson https://gis.willcountyillinois.com/hosting/rest/services/PoliticalLayers/Precincts/MapServer/0 - | \
	mapshaper -i - \
	-rename-fields precinct=NAME \
	-o $@

data/precincts/williamson.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "199"' \
	-each 'precinct = precinct.replace(" TWP", "").replace("CORINTH", "CORINTH 1").replace("GRASSY", "GRASSY 1").replace("EM09 EAST MARION", "EAST MARION 9").replace("EM10 EAST MARION", "EAST MARION 10")' \
	-o $@

# Cherry Valley 12, Cherry Valley 9, Harlem 18, Harlem 4
data/precincts/winnebago.geojson: input/precincts/Shapefiles_2020.shp
	mapshaper -i $< \
	-proj crs=wgs84 \
	-rename-fields precinct=PCTNAME \
	-dissolve2 precinct \
	-o $@

input/precincts/Shapefiles_2020.shp: input/foia/Shapefiles_2020.zip
	unzip -u $< -d $(dir $@)

data/precincts/woodford.geojson:
	pipenv run esri2geojson https://services.arcgis.com/pPTAs43AFhhk0pXQ/ArcGIS/rest/services/WoodfordCounty_Election_Polling_Places/FeatureServer/1 $@

data/precincts/city-of-bloomington.geojson: input/precincts/mclean.geojson
	mapshaper -i $< \
	-filter 'precinct.includes("City of Bloomington")' \
	-each 'precinct = "Precinct " + (+PRECINCTID).toString()' \
	-o $@

data/precincts/city-of-chicago.geojson: input/precincts/city-of-chicago.geojson input/precincts/city-of-chicago-wards.geojson data/precincts/dupage.geojson
	mapshaper -i $< \
	-clip $(word 2,$^) \
	-erase $(word 3,$^) \
	-o $@

input/precincts/city-of-chicago.geojson:
	wget -O - https://raw.githubusercontent.com/datamade/chicago-municipal-elections/master/precincts/2019_precincts.geojson | \
	mapshaper -i - \
	-rename-fields precinct_num=PRECINCT \
	-each 'precinct = WARD.toString().padStart(2, "0") + precinct_num.toString().padStart(3, "0")' \
	-o $@

input/precincts/city-of-chicago-wards.geojson:
	wget -O $@ 'https://data.cityofchicago.org/api/geospatial/sp34-6z76?method=export&format=GeoJSON'

data/precincts/city-of-danville.geojson:
	pipenv run esri2geojson https://utility.arcgis.com/usrsvcs/servers/463571faad874d958bcf15661f49f25c/rest/services/Administrative/Voting_Precincts/MapServer/1 $@

data/precincts/city-of-east-st-louis.geojson: input/precincts/st-clair.geojson
	mapshaper -i $< \
	-filter 'prec_name1.includes("East St")' \
	-rename-fields precinct=prec_name2 \
	-each 'precinct = precinct.replace("East", "E")' \
	-o $@

data/precincts/city-of-galesburg.geojson: input/precincts/Galesburg_City_Council_Wards.shp
	mapshaper -i $< -o $@

input/precincts/Galesburg_City_Council_Wards.shp: input/precincts/city-of-galesburg.zip
	unzip -u $< -d $(dir $@)

input/precincts/city-of-galesburg.zip:
	wget -O $@ https://opendata.arcgis.com/datasets/5c909cb0bf8b41d4926e0464645bc2e2_0.zip

# Missing 1404
data/precincts/city-of-rockford.geojson:
	pipenv run python scripts/scrape_clarity.py https://results.enr.clarityelections.com/WRC/Rockford/107126/270015/json/3a6d9b2e-0e2b-467c-9450-d30f9bd379ee.json "city-of-rockford" | \
	mapshaper -i - \
	-rename-fields precinct=Name \
	-dissolve2 precinct \
	-o $@

input/precincts/il_2016.geojson: input/precincts/il_2016.shp
	mapshaper -i $< -proj wgs84 -filter-fields COUNTYFP,NAME -rename-fields precinct=NAME -o $@

input/precincts/il_2016.shp: input/precincts/il_2016.zip
	unzip -u $< -d $(dir $@)

# Citation guidelines https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/NH5S2I/IJPOUH&version=46.0
# https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/NH5S2I/A652IT&version=46.0
input/precincts/il_2016.zip:
	wget -O $@ 'https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/NH5S2I/IJPOUH'

data/results-unofficial/boone.csv: input/results-unofficial/boone-constitution.csv input/results-unofficial/boone-president.csv
	xsv join --no-headers 1 $< 1 $(filter-out $<,$^) | \
	pipenv run python scripts/process_boone_results.py > $@

input/results-unofficial/boone-constitution.csv: input/results-unofficial/boone.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,36,40,44,48,53,57,61 -a %25,0,100,100 -p 1-6 $< | \
	pipenv run python scripts/process_flatten_precinct_csv.py > $@

input/results-unofficial/boone-president.csv: input/results-unofficial/boone.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,36,40,44 -a %25,0,100,100 -p 8-13 $< | \
	pipenv run python scripts/process_flatten_precinct_csv.py > $@

input/results-unofficial/boone.pdf:
	wget -O $@ https://cms8.revize.com/revize/booneil/Departments/Clerk-Recorder/voting/2020_nov_03_il_boone_SOVCDetail.pdf

data/results-unofficial/brown.csv: input/results-unofficial/brown-registered.csv input/results-unofficial/brown-results.csv
	xsv join precinct $< precinct $(filter-out $<,$^) | \
	xsv select 'id,authority,place,ward,precinct,ballots,registered,"us-president-dem","us-president-rep","us-president-votes","il-constitution-yes","il-constitution-no","il-constitution-votes"' > $@

input/results-unofficial/brown-registered.csv:
	pipenv run python scripts/scrape_platinum_registered.py https://platinumelectionresults.com/turnouts/precincts/127 > $@

input/results-unofficial/brown-results.csv:
	wget -qO - 'https://platinumelectionresults.com/reports/township/127/pd/12384,12383,12382,12381,12380,12379,12378,12377,12376,12375,12374,12373,12372,12371' | \
	pipenv run python scripts/process_platinum_results.py brown > $@

data/results-unofficial/calhoun.csv:
	wget -qO - 'https://platinumelectionresults.com/reports/township/57/pd/13957,13956,13955,13954,13953,13952,13951' | \
	pipenv run python scripts/process_platinum_results.py calhoun | \
	mapshaper -i - format=csv -each 'precinct = precinct.toUpperCase()' -o $@

data/results-unofficial/carroll.csv: input/manual/carroll.csv
	cp $< $@

data/results-unofficial/champaign.csv:
	wget -qO - https://ccco-results.s3.us-east-2.amazonaws.com/2020/docs/march/11_03_2020_precinct.HTM | \
	pipenv run python scripts/process_text_results.py champaign > $@

data/results-unofficial/christian.csv: input/results-unofficial/christian-constitution.csv input/results-unofficial/christian-president.csv
	xsv join 1 $< 1 $(filter-out $<,$^) | \
	pipenv run python scripts/process_sovc_wide_results.py christian > $@

input/results-unofficial/christian-president.csv: input/results-unofficial/christian.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,36,39.4,44,48.5,57,65,73.5 -a %25,0,100,100 -p 2 $< | \
	xsv slice -s 1 | \
	xsv select 1-3,6,4 > $@

input/results-unofficial/christian-constitution.csv: input/results-unofficial/christian.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,36,40,44,50,53,58,61 -a %25,0,100,100 -p 1 $< | \
	xsv slice -s 1 | \
	xsv select 1-3,7-8,10 > $@

input/results-unofficial/christian.pdf:
	wget -O $@ https://christiancountyil.com/wp-content/uploads/2020-nov-3-il-christian-SOVC.pdf

data/results-unofficial/clinton.csv:
	wget -qO - 'https://platinumelectionresults.com/reports/township/10/pd/13621,13601,13599,13598,13597,13596,13595,13594,13593,13600,13592,13590,13589,13588,13616,13615,13614,13613,13620,13612,13610,13609,13608,13607,13606,13605,13604,13583,13587,13586,13585,13584,13591,13602,13611,13603,13619,13618,13617' | \
	pipenv run python scripts/process_platinum_results.py clinton | \
	mapshaper -i - format=csv -each 'precinct = precinct.toUpperCase()' -o $@

data/results-unofficial/cook.csv:
	pipenv run python scripts/scrape_cook_results.py > $@

data/results-unofficial/crawford.csv: input/results-unofficial/crawford-constitution.csv input/results-unofficial/crawford-president.csv
	xsv join --no-headers 1 $< 1 $(filter-out $<,$^) | \
	pipenv run python scripts/process_sovc_tall_results.py crawford > $@

input/results-unofficial/crawford-constitution.csv: input/results-unofficial/crawford.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,37,43,48,54,60,64,69 -a %27,0,100,100 -p 1 $< | \
	xsv select --no-headers 1-3,7-8,10 > $@

input/results-unofficial/crawford-president.csv: input/results-unofficial/crawford.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,37,43,48,54,60,64,69 -a %27,0,100,100 -p 2 $< | \
	xsv select --no-headers 1,4-5,7 > $@

input/results-unofficial/crawford.pdf:
	wget -O $@ https://crawfordcountyil.org/wp-content/uploads/2020/11/statement-1.pdf

data/results-unofficial/dekalb.csv:
	pipenv run python scripts/scrape_election_console_results.py dekalb 'http://dekalb.il.electionconsole.com/electionsummary.php?e=2020%20General' > $@

input/results-unofficial/dupage.zip:
	wget -O $@ 'https://www.dupageresults.com//IL/DuPage/106122/270950/reports/detailxml.zip'

data/results-unofficial/fayette.csv:
	wget -qO - 'https://platinumelectionresults.com/reports/township/15/pd/13884,13883,13858,13859,13860,13861,13862,13863,13864,13865,13866,13867,13868,13869,13870,13871,13872,13873,13874,13875,13876,13877,13878,13879,13880,13881,13882,13857' | \
	pipenv run python scripts/process_platinum_results.py fayette | \
	mapshaper -i - format=csv -each 'precinct = precinct.toUpperCase()' -o $@

data/results-unofficial/ford.csv: input/manual/ford.csv
	cp $< $@

data/results-unofficial/franklin.csv:
	wget -qO - 'https://platinumelectionresults.com/reports/township/21/pd/13917,13923,13933,13941,13934,13948,13947,13946,13945,13944,13943,13950,13932,13930,13929,13928,13927,13926,13925,13931,13924,13922,13921,13920,13919,13918,13949,13942,13940,13939,13938,13937,13936,13935,13916' | \
	pipenv run python scripts/process_platinum_results.py franklin | \
	mapshaper -i - format=csv -each 'precinct = precinct.toUpperCase()' -o $@

data/results-unofficial/grundy.csv: input/manual/grundy.csv
	cp $< $@

data/results-unofficial/henry.csv:
	wget -qO - 'https://platinumelectionresults.com/reports/township/76/pd/13507,13506,13478,13477,13476,13475,13474,13473,13472,13471,13470,13469,13479,13468,13466,13465,13464,13463,13462,13461,13460,13459,13458,13457,13467,13480,13481,13482,13505,13504,13503,13502,13501,13500,13499,13498,13497,13496,13495,13494,13493,13492,13491,13490,13489,13488,13487,13486,13485,13484,13483,13456' | \
	pipenv run python scripts/process_platinum_results.py henry | \
	mapshaper -i - format=csv -each 'precinct = precinct.toUpperCase()' -o $@

data/results-unofficial/jefferson.csv: input/manual/jefferson.csv
	cp $< $@

data/results-unofficial/jersey.csv:
	wget -qO - 'https://www.jerseycountyclerk-il.com/wp-content/2020-elections/20GILJER/el45a.HTM' | \
	pipenv run python scripts/process_text_results.py jersey > $@

data/results-unofficial/jo-daviess.csv:
	pipenv run python scripts/scrape_jo_daviess_results.py > $@ 

data/results-unofficial/kane.csv:
	pipenv run python scripts/scrape_kane_results.py > $@

input/results-unofficial/kankakee.zip:
	wget -O $@ https://results.enr.clarityelections.com//IL/Kankakee/106271/267759/reports/detailxml.zip

# TODO: Pending
# data/results-unofficial/kendall.csv:
# 	pipenv run python scripts/scrape_election_console_results.py kendall 'http://kendall.il.electionconsole.com/electionsummary.php?e=2020%20General%20Election' > $@

data/results-unofficial/lake.csv: input/results-unofficial/lake.zip
	unzip -p $< | pipenv run python scripts/scrape_clarity_results.py lake | \
	mapshaper -i - format=csv \
	-each 'precinct = precinct.split(" ").slice(-1)[0]' \
	-o $@

input/results-unofficial/lake.zip:
	wget -O $@ https://results.enr.clarityelections.com//IL/Lake/105841/270844/reports/detailxml.zip

data/results-unofficial/lasalle.csv: input/results-unofficial/lasalle.csv input/results-unofficial/lasalle-president.csv
	xsv join --no-headers 1 $< 1 $(filter-out $<,$^) | \
	pipenv run python scripts/process_lasalle_results.py > $@

input/results-unofficial/lasalle.csv: input/results-unofficial/lasalle-turnout.csv input/results-unofficial/lasalle-constitution.csv
	xsv join --no-headers 1 $< 1 $(filter-out $<,$^) | \
	xsv select --no-headers 1-3,5-6 > $@

input/results-unofficial/lasalle-turnout.csv: input/results-unofficial/lasalle.pdf
	java -jar bin/tabula.jar -c %25,40,42,45 -p 1-4 $< | \
	xsv search --no-headers '\.' | \
	xsv search --no-headers '^\d{4}' | \
	xsv select --no-headers 1-2,4 > $@

input/results-unofficial/lasalle-constitution.csv: input/results-unofficial/lasalle.pdf
	java -jar bin/tabula.jar -c %25,40 -p 4-7 $< | \
	xsv search --no-headers --invert-match '[\.=-]' | \
	xsv search --no-headers '^\d{4}' | \
	xsv search --no-headers --invert-match '\d{6}' > $@

input/results-unofficial/lasalle-president.csv: input/results-unofficial/lasalle.pdf
	java -jar bin/tabula.jar -c %25,40,45,50,55,60,65 -p 7-10 $< | \
	xsv search --no-headers '^\d{4}' | \
	xsv search --no-headers --select 8 '\d' > $@

input/results-unofficial/lasalle.pdf:
	wget -O $@ https://15wb253pgifv3qzuu9h7yren-wpengine.netdna-ssl.com/wp-content/uploads/2020/11/2020-general-election.pdf

# TODO: Add headers, details
data/results-unofficial/lee.csv: input/results-unofficial/lee-constitution.csv input/results-unofficial/lee-president.csv
	xsv join --no-headers 1 $< 1 $(filter-out $<,$^) | \
	pipenv run python scripts/process_lee_results.py > $@

input/results-unofficial/lee-constitution.csv: input/results-unofficial/lee.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,37,43,48,54,60,72,76,81,87 -a %27,0,100,100 -p 1 $< | \
	xsv select --no-headers 1-3,7,10,12 > $@

input/results-unofficial/lee-president.csv: input/results-unofficial/lee.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,37,43,48,54,60,65,70,75,82 -a %27,0,100,100 -p 2 $< | \
	xsv select --no-headers 1,2,4,8,10,12 > $@

input/results-unofficial/lee.pdf:
	wget -O $@ https://www.leecountyil.com/DocumentCenter/View/1457/11032020Final-Official-Results

data/results-unofficial/macoupin.csv: input/results-unofficial/macoupin-constitution.csv input/results-unofficial/macoupin-president.csv
	xsv join 1 $< 1 $(filter-out $<,$^) | \
	pipenv run python scripts/process_sovc_wide_results.py macoupin > $@

input/results-unofficial/macoupin-president.csv: input/results-unofficial/macoupin.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,36,39.4,44,48.5,57,65,73.5 -a %25,0,100,100 -p 3-4 $< | \
	xsv slice -s 1 | \
	xsv select 1-4,6 > $@

input/results-unofficial/macoupin-constitution.csv: input/results-unofficial/macoupin.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,36,40,44,50,53,58,61 -a %25,0,100,100 -p 1-2 $< | \
	xsv slice -s 1 | \
	xsv select 1-3,7-8,10 > $@

input/results-unofficial/macoupin.pdf:
	wget -O $@ https://www.macoupinvotes.com/wp-content/uploads/2020/11/2020_nov_03_il_macoupin_SOVC.pdf

data/results-unofficial/madison.csv: input/results-unofficial/madison.json
	cat $< | pipenv run python scripts/process_madison.py > $@

input/results-unofficial/madison.json:
	wget -O $@ 'https://services.arcgis.com/Z0kKj2K728ngqqrp/ArcGIS/rest/services/ElectionResults_join/FeatureServer/1/query?where=%28contest%3D%27AMENDMENT+QUESTION%27+OR+contest%3D%27PRESIDENT+AND+VICE+PRESIDENT%27%29+AND+jurisdictiontype%3D%27Precinct%27&objectIds=&time=&resultType=none&outFields=jurisdictionname%2Cregvoters%2Cballotscast%2Ccontest%2Ccandidate%2Cnumvotes&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token='

data/results-unofficial/marion.csv:
	wget -qO - 'https://platinumelectionresults.com/reports/township/18/pd/13754,13753,13727,13726,13725,13724,13723,13722,13718,13716,13715,13714,13713,13712,13711,13710,13709,13708,13717,13729,13730,13731,13752,13751,13750,13749,13748,13747,13746,13745,13744,13743,13742,13741,13740,13739,13738,13737,13736,13735,13734,13733,13732,13707,13721,13720,13719,13728' | \
	pipenv run python scripts/process_platinum_results.py marion | \
	mapshaper -i - format=csv -each 'precinct = precinct.toUpperCase()' -o $@

data/results-unofficial/mclean.csv: input/manual/mclean.csv
	cp $< $@

data/results-unofficial/mercer.csv:
	wget -qO - 'http://www.mercercountyil.org/Portals/MercerCounty/Public_Documents/Elections/2020/General%20Election/11-03-20%20Precinct%20Report%20-%20Unofficial%20Results.txt' | \
	pipenv run python scripts/process_text_results.py mercer > $@

data/results-unofficial/mcdonough.csv: input/results-unofficial/mcdonough-constitution.csv input/results-unofficial/mcdonough-president.csv
	xsv join --no-headers 1 $< 1 $(filter-out $<,$^) | \
	pipenv run python scripts/process_sovc_tall_results.py mcdonough > $@

input/results-unofficial/mcdonough-constitution.csv: input/results-unofficial/mcdonough.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,37,43,48,54,60,64,69 -a %25,0,100,100 -p 1 $< | \
	xsv select --no-headers 1-3,7-8,10 > $@

input/results-unofficial/mcdonough-president.csv: input/results-unofficial/mcdonough.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,37,43,48,54,60,64,69 -a %25,0,100,100 -p 2 $< | \
	xsv select --no-headers 1,4-5,7 > $@

input/results-unofficial/mcdonough.pdf:
	wget -O $@ https://www.mcdonoughelections.com/results-2.pdf

input/results-unofficial/mchenry.zip:
	wget -O $@ https://results.enr.clarityelections.com//IL/McHenry/105201/271712/reports/detailxml.zip

data/results-unofficial/monroe.csv:
	wget -qO - 'https://platinumelectionresults.com/reports/township/12/pd/13651,13666,13668,13685,13669,13684,13683,13682,13681,13680,13679,13678,13677,13676,13675,13674,13673,13672,13671,13670,13650,13686,13667,13665,13664,13663,13662,13661,13660,13659,13658,13657,13656,13655,13654,13653,13652' | \
	pipenv run python scripts/process_platinum_results.py monroe | \
	mapshaper -i - format=csv \
	-each 'precinct = precinct.replace("Precinct ", "")' \
	-o $@

data/results-unofficial/montgomery.csv:
	wget -qO - 'https://montgomeryco.com/countyclerk/EL30.HTM' | \
	pipenv run python scripts/process_text_results.py montgomery > $@

data/results-unofficial/ogle.csv:
	pipenv run python scripts/scrape_ogle_results.py | \
	pipenv run python scripts/process_text_results.py ogle > $@

# data/results-unofficial/peoria.csv: input/results-unofficial/peoria-turnout.csv input/results-unofficial/peoria-president.csv
# 	xsv join precinct $< precinct $(filter-out $<,$^) > $@

# input/results-unofficial/peoria-turnout.csv:
# 	pipenv run esri2geojson https://services.arcgis.com/iPiPjILCMYxPZWTc/ArcGIS/rest/services/PeoriaCountyElectionResults/FeatureServer/1 - | \
# 	mapshaper -i - -rename-fields precinct=PRECINCTID,registered=REGVOTERS,ballots=TOTBALLOTS -filter-fields precinct,registered,ballots -o $@

# input/results-unofficial/peoria-president.csv:
# 	pipenv run esri2geojson https://services.arcgis.com/iPiPjILCMYxPZWTc/ArcGIS/rest/services/PeoriaCountyElectionResults/FeatureServer/3 - | \
# 	mapshaper -i - -rename-fields precinct=PRECINCTID,totalvotes=Total_candidate_Votes -filter-fields precinct,CANDIDATE,PARTY,NUMVOTES,totalvotes -o format=csv - | \
# 	pipenv run python scripts/process_peoria_results.py > $@

# input/results-unofficial/peoria.pdf:
# 	wget -O $@ https://peoriaelections.org/DocumentCenter/View/502/official-precinct

# input/results-unofficial/peoria-turnout.pdf:
# 	wget -O $@ https://peoriaelections.org/DocumentCenter/View/503/official-precinct_turnout

data/results-unofficial/pike.csv:
	wget -qO - 'https://platinumelectionresults.com/reports/township/103/pd/13915,13899,13886,13887,13888,13889,13890,13891,13892,13893,13894,13895,13896,13897,13898,13900,13914,13901,13902,13903,13904,13905,13906,13907,13908,13909,13910,13911,13912,13913,13885' | \
	pipenv run python scripts/process_platinum_results.py pike | \
	mapshaper -i - format=csv -each 'precinct = precinct.toUpperCase()' -o $@

# TODO: Not currently published
# data/results-unofficial/pulaski.csv:
# 	wget -qO - 'https://platinumelectionresults.com/reports/township/19/pd/13111,13112,13113,13114,13115,13116,13117,13106,13107,13108,13109,13110' | \
# 	pipenv run python scripts/process_platinum_results.py pulaski | \
# 	mapshaper -i - format=csv -each 'precinct = precinct.toUpperCase()' -o $@

data/results-unofficial/randolph.csv:
	wget -qO - 'https://platinumelectionresults.com/reports/township/13/pd/13809,13807,13806,13805,13804,13803,13802,13801,13800,13799,13798,13797,13796,13795,13794,13793,13808,13810,13827,13811,13826,13825,13824,13823,13822,13821,13820,13819,13818,13817,13816,13815,13814,13813,13812,13792,13828' | \
	pipenv run python scripts/process_platinum_results.py randolph | \
	mapshaper -i - format=csv -each 'precinct = precinct.toUpperCase()' -o $@

data/results-unofficial/rock-island.csv: input/results-unofficial/rock-island.csv input/results-unofficial/rock-island-president.csv
	xsv join --no-headers 1 $< 1 $(filter-out $<,$^) | \
	pipenv run python scripts/process_rock_island_results.py > $@

input/results-unofficial/rock-island.csv: input/results-unofficial/rock-island-turnout.csv input/results-unofficial/rock-island-constitution.csv	
	xsv join --no-headers 1 $< 1 $(filter-out $<,$^) | \
	xsv select --no-headers 1-3,5-6 > $@

input/results-unofficial/rock-island-turnout.csv: input/results-unofficial/rock-island.pdf
	java -jar bin/tabula.jar -c %23,27.5,32 -a %22,0,100,100 -p 1-2 $< | \
	xsv select --no-headers 1-3 > $@

input/results-unofficial/rock-island-constitution.csv: input/results-unofficial/rock-island.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,37,43,48,54,60,64,69 -a %22,0,100,100 -p 3-4 $< | \
	xsv select --no-headers 1,7,9 > $@

input/results-unofficial/rock-island-president.csv: input/results-unofficial/rock-island-president-1.csv input/results-unofficial/rock-island-president-2.csv
	xsv join --no-headers 1 $< 1 $(filter-out $<,$^) | \
	xsv select --no-headers 1-5,7-8 > $@

input/results-unofficial/rock-island-president-1.csv: input/results-unofficial/rock-island.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,37,43,48,54,60,64,69,75,80,86 -a %22,0,100,100 -p 5-6 $< | \
	xsv select --no-headers 1,7,9,11,13 > $@

input/results-unofficial/rock-island-president-2.csv: input/results-unofficial/rock-island.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,37 -a %22,0,100,100 -p 7-8 $< | \
	xsv select --no-headers 1-2,4 > $@

input/results-unofficial/rock-island.pdf:
	wget -O $@ 'https://www.rockislandcounty.org/uploadedFiles/CountyClerk/Elections/ElectionResults/Official%20Election%20Results%20Pct%20by%20Pct%2011%203%202020.pdf'

data/results-unofficial/sangamon.csv:
	pipenv run python scripts/scrape_sangamon_results.py > $@

data/results-unofficial/st-clair.csv: input/results-unofficial/st-clair-results.csv input/results-unofficial/st-clair-registered.csv
	xsv join precinct $< precinct $(filter-out $<,$^) | \
	xsv select 'id,authority,place,ward,precinct,ballots,registered,"us-president-dem","us-president-rep","us-president-votes","il-constitution-yes","il-constitution-no","il-constitution-votes"' > $@

input/results-unofficial/st-clair-registered.csv:
	pipenv run python scripts/scrape_platinum_registered.py https://stclair.platinumelectionresults.com/turnouts/precincts/6 > $@

input/results-unofficial/st-clair-results.csv:
	wget -qO - 'https://stclair.platinumelectionresults.com/reports/township/6/pd/12601,12553,12479,12478,12477,12476,12475,12474,12473,12472,12471,12480,12470,12468,12467,12466,12465,12464,12463,12462,12461,12460,12469,12482,12493,12483,12503,12502,12501,12500,12499,12498,12497,12496,12495,12525,12524,12523,12522,12521,12520,12519,12528,12518,12438,12437,12436,12481,12505,12506,12507,12575,12574,12573,12572,12571,12570,12569,12568,12567,12576,12566,12564,12563,12562,12561,12560,12559,12558,12557,12594,12593,12592,12591,12600,12590,12588,12587,12586,12585,12584,12583,12582,12581,12580,12555,12577,12554,12529,12527,12526,12509,12508,12517,12531,12551,12550,12490,12489,12488,12547,12530,12541,12504,12494,12492,12491,12552,12542,12540,12539,12535,12549,12548,12458,12457,12445,12431,12430,12429,12428,12427,12426,12425,12424,12423,12422,12421,12420,12419,12418,12534,12546,12532,12417,12416,12415,12414,12413,12432,12433,12434,12435,12455,12454,12453,12452,12451,12450,12449,12448,12447,12456,12446,12444,12443,12442,12441,12440,12439,12538,12537,12536,12533,12412,12487,12486,12485,12484,12459,12545,12544,12543,12510,12556,12565,12578,12589,12579,12599,12598,12597,12596,12595,12516,12515,12514,12513,12512,12511' | \
	pipenv run python scripts/process_platinum_results.py st-clair > $@

data/results-unofficial/stark.csv: input/manual/stark.csv
	cp $< $@

data/results-unofficial/tazewell.csv: input/results-unofficial/tazewell-constitution.csv input/results-unofficial/tazewell-president.csv
	xsv join 1 $< 1 $(filter-out $<,$^) | \
	pipenv run python scripts/process_sovc_wide_results.py tazewell > $@

input/results-unofficial/tazewell-president.csv: input/results-unofficial/tazewell.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,36,39.4,44,48.5,57,65,73.5 -a %25,0,100,100 -p 4-6 $< | \
	xsv slice -s 1 | \
	xsv select 1-4,6 > $@

input/results-unofficial/tazewell-constitution.csv: input/results-unofficial/tazewell.pdf
	java -jar bin/tabula.jar -c %23,27.5,32,36,40,44,50,53,58,61 -a %25,0,100,100 -p 1-3 $< | \
	xsv slice -s 1 | \
	xsv select 1-3,7-8,10 > $@

input/results-unofficial/tazewell.pdf:
	wget -O $@ https://www.tazewell.com/countyclerk/images/Elections/2020-Nov-03-Official-of-Votes-Cast.pdf

data/results-unofficial/union.csv:
	wget -qO - 'https://platinumelectionresults.com/reports/township/16/pd/13706,13705,13688,13689,13690,13691,13692,13693,13694,13695,13696,13697,13698,13699,13700,13701,13702,13703,13704,13687' | \
	pipenv run python scripts/process_platinum_results.py union | \
	mapshaper -i - format=csv -each 'precinct = precinct.toUpperCase()' -o $@

input/results-unofficial/vermilion.zip:
	wget -O $@ https://results.enr.clarityelections.com//IL/Vermilion/107170/271697/reports/detailxml.zip

data/results-unofficial/wayne.csv:
	wget -qO - 'https://platinumelectionresults.com/reports/township/14/pd/13534,13520,13509,13510,13525,13526,13527,13528,13529,13530,13531,13532,13508,13511,13512,13513,13514,13515,13516,13517,13518,13519,13521,13533,13522,13523,13524' | \
	pipenv run python scripts/process_platinum_results.py wayne | \
	mapshaper -i - format=csv -each 'precinct = precinct.toUpperCase()' -o $@

input/results-unofficial/will.zip:
	wget -O $@ https://results.enr.clarityelections.com//IL/Will/106272/267921/reports/detailxml.zip

data/results-unofficial/williamson.csv:
	wget -qO - 'https://platinumelectionresults.com/reports/township/51/pd/13455,13422,13420,13419,13418,13417,13416,13415,13414,13413,13412,13411,13410,13409,13408,13407,13406,13405,13404,13403,13402,13401,13400,13399,13398,13397,13396,13395,13394,13393,13392,13421,13423,13454,13424,13453,13452,13451,13450,13449,13448,13447,13446,13445,13444,13443,13442,13441,13440,13439,13438,13437,13436,13435,13434,13433,13432,13431,13430,13429,13428,13427,13426,13425,13391' | \
	pipenv run python scripts/process_platinum_results.py williamson | \
	mapshaper -i - format=csv -each 'precinct = precinct.toUpperCase()' -o $@

data/results-unofficial/winnebago.csv: input/results-unofficial/winnebago.zip
	unzip -p $< | pipenv run python scripts/scrape_clarity_results.py winnebago upper > $@

input/results-unofficial/winnebago.zip:
	wget -O $@ https://results.enr.clarityelections.com/WRC/Winnebago/107127/268257/reports/detailxml.zip

input/results-unofficial/city-of-bloomington.zip:
	wget -O $@ https://results.enr.clarityelections.com//IL/Bloomington/107152/271705/reports/detailxml.zip

data/results-unofficial/city-of-chicago.csv:
	pipenv run python scripts/scrape_chicago_results.py > $@

data/results-unofficial/city-of-east-st-louis.csv: input/results-unofficial/city-of-east-st-louis-results.csv input/results-unofficial/city-of-east-st-louis-registered.csv
	xsv join precinct $< precinct $(filter-out $<,$^) | \
	xsv select 'id,authority,place,ward,precinct,ballots,registered,"us-president-dem","us-president-rep","us-president-votes","il-constitution-yes","il-constitution-no","il-constitution-votes"' > $@

input/results-unofficial/city-of-east-st-louis-registered.csv:
	pipenv run python scripts/scrape_platinum_registered.py https://stclair.platinumelectionresults.com/turnouts/precincts/48 > $@

input/results-unofficial/city-of-east-st-louis-results.csv:
	wget -qO - 'https://stclair.platinumelectionresults.com/reports/township/48/pd/11551,11537,11544,11545,11546,11547,11548,11549,11527,11538,11528,11529,11530,11531,11532,11533,11534,11535,11536,11539,11550,11540,11541,11542,11543' | \
	pipenv run python scripts/process_platinum_results.py city-of-east-st-louis > $@

input/results-unofficial/city-of-rockford.zip:
	wget -O $@ https://results.enr.clarityelections.com/WRC/Rockford/107126/271677/reports/detailxml.zip

data/results-unofficial/%.csv: input/results-unofficial/%.zip
	unzip -p $< | pipenv run python scripts/scrape_clarity_results.py $* > $@
