PRECINCT_FILES := $(shell cat input/jurisdictions.txt | xargs -I {} echo "data/precincts/{}.geojson")

all: $(PRECINCT_FILES)

.PHONY: clean
clean:
	rm -f data/precincts/*.* input/precincts/*.*

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
	mapshaper -i - -rename-fields precinct_num=Precinct -rename-fields precinct=TWP_PRECIN -o $@

data/precincts/brown.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "009"' -o $@

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
	mapshaper -i $< -proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-88.33333333333333 +k=0.999975 +x_0=300000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 -o $@

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
	mapshaper -i $< -filter 'COUNTYFP === "051"' -o $@

data/precincts/ford.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "053"' -o $@

data/precincts/franklin.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "055"' -o $@

data/precincts/fulton.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "057"' -o $@

data/precincts/gallatin.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "059"' -o $@

data/precincts/greene.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "061"' -o $@

data/precincts/grundy.geojson:
	pipenv run esri2geojson https://maps.grundyco.org/arcgis/rest/services/CountyClerk/PollingPlaces_SPIE_Public/FeatureServer/1 $@

data/precincts/hamilton.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "065"' -o $@

data/precincts/hancock.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "067"' -o $@

data/precincts/hardin.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "069"' -o $@

data/precincts/henderson.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "071"' -o $@

data/precincts/henry.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "073"' -o $@

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
	mapshaper -i $< -proj wgs84 -o $@

input/precincts/Kendall_County_Voting_Precinct.shp: input/precincts/kendall.zip
	unzip -u $< -d $(dir $@)

input/precincts/kendall.zip:
	wget -O $@ 'https://opendata.arcgis.com/datasets/bc2430d057cb487aa51273e4e8762c2e_0.zip?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D'

data/precincts/knox.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "095" && !precinct.includes("GALESBURG CITY")' -o $@

data/precincts/lake.geojson:
	pipenv run python scripts/scrape_clarity.py https://results.enr.clarityelections.com//IL/Lake/105841/271143/json/7cdabc13-5da7-496f-9853-8604f5b68072.json Lake | \
	mapshaper -i - -rename-fields precinct=Name -o $@

data/precincts/lasalle.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "099"' -o $@

data/precincts/lawrence.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "101"' -o $@

data/precincts/lee.geojson:
	pipenv run esri2geojson https://gis.leecountyil.com/server/rest/services/Election/Election_Precincts/MapServer/0 $@

data/precincts/livingston.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "105"' -o $@

data/precincts/logan.geojson:
	pipenv run esri2geojson https://www.centralilmaps.com/arcgis/rest/services/Logan/Logan_Flex_1/MapServer/40 $@

data/precincts/macon.geojson:
	pipenv run esri2geojson https://services1.arcgis.com/a3k0qIja5SolIRYR/ArcGIS/rest/services/ElectionGeography_public/FeatureServer/1 $@

data/precincts/macoupin.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/MacoupinIL/MacoupinIL_PAT_GIS/MapServer/4 $@

data/precincts/madison.geojson:
	pipenv run esri2geojson https://services.arcgis.com/Z0kKj2K728ngqqrp/ArcGIS/rest/services/ElectionGeography_public/FeatureServer/1 - | \
	mapshaper -i - -rename-fields precinct=name -filter-fields precinct -o $@

data/precincts/marion.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "121"' -o $@

data/precincts/marshall.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "123"' -o $@

data/precincts/mason.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "125"' -o $@

data/precincts/massac.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "127"' -o $@

data/precincts/mcdonough.geojson:
	pipenv run python scripts/scrape_mcdonough.py | \
	mapshaper -i - -proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-90.16666666666667 +k=0.999941 +x_0=700000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 -o $@

data/precincts/mchenry.geojson:
	pipenv run esri2geojson https://www.mchenrycountygis.org/arcgis/rest/services/County_Board/Precincts/MapServer/0 $@

data/precincts/mclean.geojson: input/precincts/mclean.geojson
	mapshaper -i $< -filter '!NAME.includes("City of Bloomington")' -o $@

input/precincts/mclean.geojson: input/precincts/Voting_Precincts.shp
	mapshaper -i $< -o $@

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
	pipenv run esri2geojson https://services.arcgis.com/AZVIEb4WFZST2UYx/arcgis/rest/services/Voter_Precincts/FeatureServer/0 $@

data/precincts/montgomery.geojson:
	pipenv run python scripts/pybeacondump.py 'https://beacon.schneidercorp.com/Application.aspx?AppID=503&LayerID=7586&PageTypeID=1&PageID=3800' 7705 - | \
	mapshaper -i - \
	-proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-90.16666666666667 +k=0.999941 +x_0=700000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 \
	-dissolve2 NAME \
	-rename-fields precinct=NAME \
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
	-o $@

data/precincts/peoria.geojson:
	pipenv run esri2geojson https://gis.peoriacounty.org/arcgis/rest/services/DP/Elections/MapServer/8 $@

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
	mapshaper -i $< -filter 'COUNTYFP === "157"' -o $@

data/precincts/richland.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "159"' -o $@

data/precincts/rock-island.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "161"' -o $@

data/precincts/saline.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "165"' -o $@

data/precincts/sangamon.geojson:
	pipenv run esri2geojson https://services.arcgis.com/XqG0RpqsNfIBGGb2/ArcGIS/rest/services/ElectionPollingAndPrecincts/FeatureServer/1 $@

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
	mapshaper -i $< -filter 'COUNTYFP === "175"' -o $@

data/precincts/stephenson.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "177"' -o $@

data/precincts/tazewell.geojson:
	pipenv run esri2geojson https://gis.tazewell.com/maps/rest/services/ElectionPoll/ElectionPollingPlaces/MapServer/1 - | \
	mapshaper -i - -each 'precinct = NAME.toUpperCase().replace("BOYTON", "BOYNTON").replace("DEERCREEK", "DEER CREEK")' -o $@

data/precincts/union.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "181"' -o $@

data/precincts/vermilion.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/VermilionIL/VermilionIL_PAT_GIS/MapServer/12 - | \
	mapshaper -i - -filter '!PRECINCT_E.includes("DANVILLE CITY")' -o $@

data/precincts/wabash.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "185"' -o $@

data/precincts/warren.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "187"' -o $@

data/precincts/washington.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "189"' -o $@

data/precincts/wayne.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "191"' -o $@

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
	mapshaper -i $< -filter 'COUNTYFP === "199"' -o $@

data/precincts/winnebago.geojson:
	pipenv run python scripts/scrape_clarity.py https://results.enr.clarityelections.com/WRC/Winnebago/107127/268257/json/cf87babd-eb26-4e37-bf3f-b3e4e62e2c52.json Winnebago | \
	mapshaper -i - \
	-rename-fields precinct=Name \
	-each 'precinct = precinct.replace("  ", " ").toUpperCase()' \
	-o $@

data/precincts/woodford.geojson:
	pipenv run esri2geojson https://services.arcgis.com/pPTAs43AFhhk0pXQ/ArcGIS/rest/services/WoodfordCounty_Election_Polling_Places/FeatureServer/1 $@

data/precincts/city-of-bloomington.geojson: input/precincts/mclean.geojson
	mapshaper -i $< -filter 'NAME.includes("City of Bloomington")' -o $@

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

data/precincts/city-of-rockford.geojson:
	pipenv run python scripts/scrape_clarity.py https://results.enr.clarityelections.com/WRC/Rockford/107126/270015/json/3a6d9b2e-0e2b-467c-9450-d30f9bd379ee.json "City of Rockford" > $@

input/precincts/il_2016.geojson: input/precincts/il_2016.shp
	mapshaper -i $< -proj wgs84 -filter-fields COUNTYFP,NAME -rename-fields precinct=NAME -o $@

input/precincts/il_2016.shp: input/precincts/il_2016.zip
	unzip -u $< -d $(dir $@)

# TODO: Citation guidelines https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/NH5S2I/IJPOUH&version=46.0
# https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/NH5S2I/A652IT&version=46.0
input/precincts/il_2016.zip:
	wget -O $@ 'https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/NH5S2I/IJPOUH'

data/results-unofficial/cook.csv:
	pipenv run python scripts/scrape_cook_results.py > $@

data/results-unofficial/champaign.csv: input/results-unofficial/champaign.txt
	cat $< | pipenv run python scripts/process_champaign_results.py > $@
	
input/results-unofficial/champaign.txt:
	wget -O $@ https://ccco-results.s3.us-east-2.amazonaws.com/2020/docs/march/11_03_2020_precinct.HTM

data/results-unofficial/kane.csv:
	pipenv run python scripts/scrape_kane_results.py > $@

# data/results-unofficial/kankakee.csv:

# TODO: https://15wb253pgifv3qzuu9h7yren-wpengine.netdna-ssl.com/wp-content/uploads/2020/11/canvass.pdf
# data/results-unofficial/lasalle.csv:

data/results-unofficial/madison.csv: input/results-unofficial/madison.json
	cat $< | pipenv run python scripts/process_madison.py > $@

input/results-unofficial/madison.json:
	wget -O $@ 'https://services.arcgis.com/Z0kKj2K728ngqqrp/ArcGIS/rest/services/ElectionResults_join/FeatureServer/1/query?where=%28contest%3D%27AMENDMENT+QUESTION%27+OR+contest%3D%27PRESIDENT+AND+VICE+PRESIDENT%27%29+AND+jurisdictiontype%3D%27Precinct%27&objectIds=&time=&resultType=none&outFields=jurisdictionname%2Cregvoters%2Cballotscast%2Ccontest%2Ccandidate%2Cnumvotes&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token='

data/results-unofficial/st-clair.csv: input/results-unofficial/st-clair-results.csv input/results-unofficial/st-clair-registered.csv
	xsv join precinct $< precinct $(filter-out $<,$^) | \
	xsv select 'id,authority,place,ward,precinct,ballots,registered,"us-president-dem","us-president-rep","us-president-votes","il-constitution-yes","il-constitution-no","il-constitution-votes"' > $@

input/results-unofficial/st-clair-registered.csv:
	pipenv run python scripts/scrape_platinum_registered.py https://stclair.platinumelectionresults.com/turnouts/precincts/6 > $@

input/results-unofficial/st-clair-results.csv:
	wget -qO - \
	'https://stclair.platinumelectionresults.com/reports/township/6/pd/12060,12062,12087,12063,12086,12085,12084,12083,12082,12081,12080,12079,12078,12077,12076,12075,12074,12073,12072,12071,12070,12069,12068,12067,12066,12065,12064,12036,12061,12035,12007,12005,12004,12003,12002,12105,12104,12103,12102,12101,12100,12099,12098,12097,12162,12161,12160,12159,12158,12157,12156,12155,12154,12153,12152,12151,12150,12149,12148,12147,12146,12145,12168,12170,12195,12171,12194,12193,12192,12191,12180,12179,12178,12177,12176,12175,12174,12173,12172,12144,12169,12143,12115,12113,12112,12111,12110,12109,12108,12107,12106,12116,12141,12117,12138,12137,12136,11997,11996,11995,12133,12140,12139,12001,12000,11999,11998,12128,12127,12126,12125,12121,12135,12134,11989,11988,11987,11986,11985,11984,11983,12006,12008,12033,12009,12032,12031,12030,12029,12028,12027,12120,12132,12118,12026,12025,12024,12023,12022,12021,12020,12019,12018,12017,12016,12015,12014,12013,12012,12011,12010,12034,12089,12142,12090,12167,12166,12165,12164,12163,12124,12123,12122,12119,11982,11994,11993,11992,11991,11990,12131,12130,12129,12114,12190,12189,12188,12187,12186,12185,12184,12183,12182,12181,12096,12095,12094,12093,12092,12091' | \
	pipenv run python scripts/process_platinum_results.py st-clair > $@

data/results-unofficial/tazewell.csv: input/results-unofficial/tazewell-constitution.csv input/results-unofficial/tazewell-president.csv
	xsv join 1 $< 1 $(filter-out $<,$^) | \
	pipenv run python scripts/process_tazewell_results.py > $@

input/results-unofficial/tazewell-president.csv: input/results-unofficial/tazewell.pdf
	java -jar scripts/tabula.jar -c %23,27.5,32,39.4,48.5,57,65,73.5 -a %25,0,100,100 -p 4-6 $< | \
	xsv slice -s 1 | \
	xsv select 1-5 > $@

input/results-unofficial/tazewell-constitution.csv: input/results-unofficial/tazewell.pdf
	java -jar scripts/tabula.jar -c %23,27.5,32,36,40,44,48,52,57 -a %25,0,100,100 -p 1-3 $< | \
	xsv slice -s 1 | \
	xsv select 1-3,6-7,9 > $@

input/results-unofficial/tazewell.pdf:
	wget -O $@ https://www.tazewell.com/countyclerk/images/Elections/Nov3-2020-Unofficial-of-Votes-Cast.pdf

data/results-unofficial/winnebago.csv: input/results-unofficial/winnebago.zip
	unzip -p $< | pipenv run python scripts/scrape_clarity_results.py winnebago upper > $@

data/results-unofficial/city-of-chicago.csv:
	pipenv run python scripts/scrape_chicago_results.py > $@

data/results-unofficial/city-of-east-st-louis.csv: input/results-unofficial/city-of-east-st-louis-results.csv input/results-unofficial/city-of-east-st-louis-registered.csv
	xsv join precinct $< precinct $(filter-out $<,$^) | \
	xsv select 'id,authority,place,ward,precinct,ballots,registered,"us-president-dem","us-president-rep","us-president-votes","il-constitution-yes","il-constitution-no","il-constitution-votes"' > $@

input/results-unofficial/city-of-east-st-louis-registered.csv:
	pipenv run python scripts/scrape_platinum_registered.py https://stclair.platinumelectionresults.com/turnouts/precincts/48 > $@

input/results-unofficial/city-of-east-st-louis-results.csv:
	wget -qO - \
	'https://stclair.platinumelectionresults.com/reports/township/48/pd/11551,11537,11544,11545,11546,11547,11548,11549,11527,11538,11528,11529,11530,11531,11532,11533,11534,11535,11536,11539,11550,11540,11541,11542,11543' | \
	pipenv run python scripts/process_platinum_results.py city-of-east-st-louis > $@

data/results-unofficial/%.csv: input/results-unofficial/%.zip
	unzip -p $< | pipenv run python scripts/scrape_clarity_results.py $* > $@

input/results-unofficial/dupage.zip:
	wget -O $@ 'https://www.dupageresults.com//IL/DuPage/106122/270950/reports/detailxml.zip'

input/results-unofficial/kankakee.zip:
	wget -O $@ https://results.enr.clarityelections.com//IL/Kankakee/106271/267759/reports/detailxml.zip

# TODO: More precincts than results rows for Lake
input/results-unofficial/lake.zip:
	wget -O $@ https://results.enr.clarityelections.com//IL/Lake/105841/270844/reports/detailxml.zip

input/results-unofficial/will.zip:
	wget -O $@ https://results.enr.clarityelections.com//IL/Will/106272/267921/reports/detailxml.zip

input/results-unofficial/winnebago.zip:
	wget -O $@ https://results.enr.clarityelections.com/WRC/Winnebago/107127/268257/reports/detailxml.zip
