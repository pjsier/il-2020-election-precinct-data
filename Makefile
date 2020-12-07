PRECINCT_FILES := $(shell cat input/jurisdictions.txt | xargs -I {} echo "output/{}.geojson")

.PRECIOUS: data/results/%.csv data/precincts/%.geojson output/%.geojson

all: $(PRECINCT_FILES)

.PHONY: clean
clean:
	rm -f output/*.geojson data/precincts/*.geojson data/results-unofficial/*.csv input/precincts/*.* input/results-unofficial/*.*

.PHONY: install
install:
	pipenv sync --dev

output/il.geojson: $(PRECINCT_FILES)
	mapshaper -i $^ combine-files \
	-filter-fields authority,precinct,registered,ballots,us-president-dem,us-president-rep,us-president-votes,il-constitution-yes,il-constitution-no,il-constitution-votes,us-senate-dem,us-senate-rep,us-senate-wil,us-senate-votes \
	-merge-layers force \
	-o $@

output/%.geojson: data/precincts/%.geojson data/results/%.csv
	mapshaper -i $< -join $(filter-out $<,$^) keys=precinct,precinct field-types=precinct:str -o $@

# MELROSE PCT 2 is "MELROSE 2" in current results
data/precincts/adams.geojson:
	pipenv run esri2geojson http://www.adamscountyarcserver.com/adamscountyarcserver/rest/services/AdamsCoBaseMapFG_2018/MapServer/43 - | \
	mapshaper -i - \
	-rename-fields precinct=Precinct \
	-each 'precinct = precinct.replace("Q ", "QUINCY ")' \
	-each 'precinct = precinct.replace("CAMP POINT ", "CAMP POINT PCT ")' \
	-each 'precinct = precinct.replace("EL ", "ELLINGTON PCT ")' \
	-each 'precinct = precinct.replace("MEL ", "MELROSE PCT ")' \
	-each 'precinct = precinct.replace("MENDON ", "MENDON PCT ")' \
	-each 'precinct = precinct.replace("PAYSON ", "PAYSON PCT ")' \
	-each 'precinct = precinct.replace("RIV ", "RIVERSIDE ")' \
	-dissolve2 precinct \
	-o $@

data/precincts/alexander.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "003"' \
	-each 'precinct = precinct.replace("MC CLURE", "MCCLURE")' \
	-o $@

data/precincts/bond.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "005"' \
	-each 'precinct = precinct.replace("1A", "1-A")' \
	-o $@

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
	-each 'precinct = precinct.replace("MT S", "MT. S").replace("VERSAILLES", "VERSAILLES TWP")' \
	-each 'precinct = precinct.match(/\d/g) ? precinct : precinct + " TWP"' \
	-o $@

data/precincts/bureau.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "011"' \
	-each 'precinct = precinct.replace(" NO ", " ").replace("LAMOILLE", "LA MOILLE")' \
	-o $@

data/precincts/calhoun.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "013"' \
	-each 'precinct = precinct.includes("-CARLIN") ? precinct + " PCT." : precinct + " PRECINCT"' \
	-o $@

data/precincts/carroll.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "015"' \
	-each 'precinct = precinct.replace("GROVE/", "GROVE ").replace("/", "-").replace("MT C", "MT. C")' \
	-o $@

data/precincts/cass.geojson:
	pipenv run python scripts/pybeacondump.py 'https://beacon.schneidercorp.com/Application.aspx?AppID=55&LayerID=375&PageTypeID=1&PageID=916' 1751 - | \
	mapshaper -i - \
	-proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-90.16666666666667 +k=0.999941 +x_0=700000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 \
	-dissolve2 Precinct \
	-rename-fields precinct=Precinct \
	-o $@

data/precincts/champaign.geojson:
	pipenv run esri2geojson --proxy https://services.ccgisc.org/proxy/proxy.ashx? https://services.ccgisc.org/server/rest/services/CountyClerk/Precincts/MapServer/0 - | \
	mapshaper -i - \
	-each 'precinct = ["AYERS", "COLFAX", "CONDIT", "CRITTENDEN", "EAST BEND", "HARWOOD", "HENSLEY", "KERR", "NEWCOMB", "PESOTUM", "PHILO", "RAYMOND", "SIDNEY", "SOMER", "SOUTH HOMER", "STANTON"].includes(TWPNAME.toUpperCase()) ? TWPNAME.toUpperCase() : TWPNAME.toUpperCase() + " " + +PrecinctNum' \
	-each 'precinct = precinct.replace("BROWN 1", "BROWN FISHER").replace("BROWN 2", "BROWN FOOSLAND").replace("COMPROMISE 1", "COMPROMISE GIFFORD").replace("COMPROMISE 2", "COMPROMISE PENFIELD").replace("SADORUS 1", "SADORUS SADORUS").replace("SADORUS 2", "SADORUS IVESDALE").replace("SCOTT 1", "SCOTT BONDVILLE").replace("SCOTT 2", "SCOTT SEYMOUR")' \
	-each 'precinct = precinct.replace("ST J", "ST. J")' \
	-o $@

data/precincts/christian.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "021"' \
	-each 'precinct = ["ASSUMPTION 1", "BUCKHART 1", "MT AUBURN 1", "RICKS 1", "STONINGTON 1"].includes(precinct) ? precinct.replace(" 1", "") : precinct.replace(/ (?=\d)/g, " #")' \
	-o $@

data/precincts/clark.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "023"' -o $@

# Larkinsburg, Pixley, Clay City all merged based on Clerk's site
# http://claycountyillinois.org/clerkrecorder/
# TODO: What happened to HARTER 2?
data/precincts/clay.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "025"' \
	-each 'precinct = precinct.replace(" VII", " 7").replace(" VI", " 6").replace(" V", " 5").replace(" IV", " 4").replace(" III", " 3").replace(" II", " 2").replace(" I", " 1")' \
	-each 'precinct = precinct.includes("LARKINSBURG") ? "LARKINSBURG" : precinct' \
	-each 'precinct = precinct.includes("PIXLEY") ? "PIXLEY" : precinct' \
	-each 'precinct = precinct.includes("CLAY CITY") ? "CLAY CITY" : precinct' \
	-dissolve2 precinct \
	-o $@

data/precincts/clinton.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "027"' -o $@

data/precincts/coles.geojson:
	pipenv run python scripts/scrape_coles.py | \
	mapshaper -i - -proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-88.33333333333333 +k=0.999975 +x_0=300000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 \
	-rename-fields precinct=PrecinctName \
	-o $@

data/precincts/cook.geojson:
	pipenv run esri2geojson https://gis12.cookcountyil.gov/arcgis/rest/services/electionSrvcLite/MapServer/1 - | \
	mapshaper -i - \
	-rename-fields precinct=Idpct_txt \
	-o $@

data/precincts/crawford.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "033"' \
	-each 'precinct = ["LICKING 1", "MARTIN 1", "MONTGOMERY 1"].includes(precinct) ? precinct.replace(" 1", "") : precinct' \
	-o $@

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
	-each 'precinct = precinct.replace(Precinct.toString(), " " + Precinct.toString().padStart(3, "0"))' \
	-o $@

data/precincts/edgar.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "045"' \
	-each 'precinct = ["EMBARRASS 1", "KANSAS 1"].includes(precinct) ? precinct.replace(" 1", "") : precinct' \
	-o $@

data/precincts/edwards.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "047"' -o $@

data/precincts/effingham.geojson:
	pipenv run esri2geojson https://services.arcgis.com/vj0V9Lal6oiz0YXp/ArcGIS/rest/services/ElectoralDistricts/FeatureServer/1 - | \
	mapshaper -i - \
	-each 'precinct = NAME.toUpperCase()' \
	-o $@

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
	mapshaper -i $< \
	-filter 'COUNTYFP === "057"' \
	-each 'precinct = precinct.includes("CANTON") ? precinct.replace(/ (?=\d$$)/g, " 0") : precinct.replace("LEE", "LEE TWP")' \
	-o $@

data/precincts/gallatin.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "059"' -o $@

data/precincts/greene.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "061"' \
	-each 'precinct = precinct.replace(" III", " 3").replace(" II", " 2").replace(" I", " 1")' \
	-each 'precinct = precinct.match(/\d/g) ? precinct : precinct + " 1"' \
	-each 'precinct = precinct.replace("WRIGHTS 1", "WRIGHTS 2")' \
	-o $@

data/precincts/grundy.geojson:
	pipenv run esri2geojson https://maps.grundyco.org/arcgis/rest/services/CountyClerk/PollingPlaces_SPIE_Public/FeatureServer/1 - | \
	mapshaper -i - \
	-each 'precinct = NAME.toUpperCase().replace(/ (?=\d$$)/g, " 0")' \
	-o $@

data/precincts/hamilton.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "065"' \
	-each 'precinct = precinct.replace(" NO ", " ").replace("FLANNINGAN", "FLANNIGAN").replace("KNIGHTS PRAIRIE 1", "KNIGHTS PRAIRIE")' \
	-o $@

data/precincts/hancock.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "067"' \
	-each 'precinct = precinct.replace(" IV", " 4").replace(" III", " 3").replace(" II", " 2").replace(" I", " 1")' \
	-each 'precinct = precinct.replace("ST ", "ST. ")' \
	-each 'precinct = precinct.replace("MONTIBELLO", "MONTEBELLO")' \
	-each 'precinct = precinct.includes("ROCKY RUN") || precinct.includes("WILCOX") ? "ROCKY RUN-WILCOX" : precinct' \
	-dissolve2 precinct \
	-o $@

data/precincts/hardin.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "069"' \
	-each 'precinct = precinct.replace(/-/g, " ")' \
	-o $@

data/precincts/henderson.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "071"' \
	-each 'precinct = precinct.replace(/ (?=\d)/g, " #")' \
	-o $@

data/precincts/henry.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "073"' \
	-each 'precinct = precinct.replace("COLONA 2", "COLONA 2 B")' \
	-o $@

data/precincts/iroquois.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/IroquoisIL/IroquoisIL_PAT_GIS/MapServer/8 - | \
	mapshaper -i - \
	-each 'precinct = Name.toUpperCase().replace("IV", "4").replace("III", "3").replace("II", "2").replace(" I", " 1")' \
	-o $@

data/precincts/jackson.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "077"' \
	-each 'precinct = precinct.toUpperCase()' \
	-o $@

data/precincts/jasper.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "079"' \
	-each 'precinct = precinct.replace("STE M", "STE. M")' \
	-o $@

data/precincts/jefferson.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "081"' \
	-each 'precinct = precinct.replace("MOUNT V", "MT. V")' \
	-each 'precinct = ["BALD HILL 1", "CASNER 1", "ELK PRAIRIE 1", "PENDLETON 1"].includes(precinct) ? precinct.replace(" 1", "") : precinct' \
	-o $@

data/precincts/jersey.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "083"' -o $@

data/precincts/jo-daviess.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "085"' -o $@

data/precincts/johnson.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "087"' -o $@

data/precincts/kane.geojson:
	pipenv run esri2geojson https://utility.arcgis.com/usrsvcs/servers/1db346a5fb5c4a5abfe52acfc97ad2a2/rest/services/Kane_Precincts/FeatureServer/0 --header Referer:'https://kanegis.maps.arcgis.com/apps/webappviewer/index.html' - | \
	mapshaper -i - \
	-rename-fields precinct=PRECINCT \
	-dissolve2 precinct \
	-each 'precinct = precinct.includes("W") ? precinct : precinct.slice(0,2) + "00" + precinct.slice(2)' \
	-o $@

data/precincts/kankakee.geojson:
	pipenv run esri2geojson https://k3gis.com/arcgis/rest/services/BASE/Elected_Officials/MapServer/0 - | \
	mapshaper -i - \
	-each 'precinct = name.toUpperCase().replace(/ (?=\d)/gi, " #").replace("NORTON #1", "NORTON")' \
	-o $@

data/precincts/kendall.geojson: input/precincts/Kendall_County_Voting_Precinct.shp
	mapshaper -i $< \
	-proj wgs84 \
	-each 'precinct = (twp_name + " " + precinct_).replace(/-/gi, " ")' \
	-dissolve2 precinct \
	-o $@

input/precincts/Kendall_County_Voting_Precinct.shp: input/precincts/kendall.zip
	unzip -u $< -d $(dir $@)

input/precincts/kendall.zip:
	wget -O $@ 'https://opendata.arcgis.com/datasets/bc2430d057cb487aa51273e4e8762c2e_0.zip?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D'

data/precincts/knox.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "095" && !precinct.includes("GALESBURG CITY")' \
	-each 'precinct = precinct.replace("GALESBURG TOWNSHIP", "GALESBURG").replace("RIO", "RIO TWP").replace("ONTARIO TWP", "ONTARIO")' \
	-each 'precinct = precinct.replace(" 1", " FIRST").replace(" 2", " SECOND").replace(" 3", " THIRD").replace(" 4", " FOURTH").replace(" 5", " FIFTH").replace(" 6", " SIX").replace(" 7", " SEVEN")' \
	-o $@

# Matches if only numbers used for CSV precincts
data/precincts/lake.geojson:
	pipenv run esri2geojson https://maps.lakecountyil.gov/arcgis/rest/services/GISMapping/WABPoliticalBoundaries/MapServer/5 - | \
	mapshaper -i - \
	-each 'precinct = PRECINCT.toString()' \
	-filter-fields precinct \
	-dissolve2 precinct \
	-o $@

data/precincts/lasalle.geojson:
	pipenv run esri2geojson http://gis.lasallecounty.org/arcgis/rest/services/CountyClerk/LaSalle_co_il_polling/MapServer/2 - | \
	mapshaper -i - \
	-rename-fields precinct=CountyClerk.DBO.VotingPrecinct.NAME \
	-each 'precinct = precinct.match(/\d/gi) ? precinct : precinct + " 1"' \
	-o $@

# TODO: Figure out how Bridgeport precincts mered
# Denison 10 and 11 merged as well as Bridgeport 4, 5, 6, and 7 based on map PDFs
# https://www.elections.il.gov/precinctmaps/Lawrence/Denison.pdf
# https://www.elections.il.gov/precinctmaps/Lawrence/Bridgeport.pdf
data/precincts/lawrence.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "101"' -o $@

data/precincts/lee.geojson:
	pipenv run esri2geojson https://gis.leecountyil.com/server/rest/services/Election/Election_Precincts/MapServer/0 - | \
	mapshaper -i - \
	-each 'precinct = LYR_NAME.toUpperCase()' \
	-filter 'precinct !== "ROCK RIVER"' \
	-each 'precinct = precinct.replace(/DIXON (?=\d$$)/g, "DIXON  ")' \
	-o $@

data/precincts/livingston.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "105"' \
	-each 'precinct = precinct.replace("INDIAN GROVE", "INDIAN GRV").replace("CHATSWORTH", "CHATSWORTH 1")' \
	-o $@

data/precincts/logan.geojson:
	pipenv run esri2geojson https://www.centralilmaps.com/arcgis/rest/services/Logan/Logan_Flex_1/MapServer/40 - | \
	mapshaper -i - \
	-each 'precinct = Name.toUpperCase().replace("/ ", "/").replace("ATLANTA 1", "ATLANTA")' \
	-o $@

data/precincts/macon.geojson:
	pipenv run esri2geojson https://services1.arcgis.com/a3k0qIja5SolIRYR/ArcGIS/rest/services/ElectionGeography_public/FeatureServer/1 - | \
	mapshaper -i - \
	-rename-fields precinct=name \
	-each 'precinct = precinct.replace("MT ", "MT. ").replace(" PT ", " PT. ").replace("AUSTIN 1", "AUSTIN").replace("BLUE MOUND 1", "BLUE MOUND").replace("NIANTIC 1", "NIANTIC").replace("MAROA 1", "MAROA").replace("FRIENDS CREEK 1", "FRIENDS CREEK").replace("SOUTH MACON 1", "SOUTH MACON")' \
	-o $@

data/precincts/macoupin.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/MacoupinIL/MacoupinIL_PAT_GIS/MapServer/4 - | \
	mapshaper -i - \
	-rename-fields precinct=PRECINCT \
	-each 'precinct = precinct.replace("HILLYARD", "HILYARD")' \
	-o $@

data/precincts/madison.geojson:
	pipenv run esri2geojson https://services.arcgis.com/Z0kKj2K728ngqqrp/ArcGIS/rest/services/ElectionGeography_public/FeatureServer/1 - | \
	mapshaper -i - \
	-each 'precinct = name.replace("LEEF 01", "LEEF  01")' \
	-o $@

data/precincts/marion.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "121"' \
	-each 'precinct = precinct.includes("CENTRALIA") ? "CENTRALIA " + precinct.split(" ").slice(-1)[0].padStart(2, "0") : precinct' \
	-o $@

data/precincts/marshall.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "123"' \
	-each 'precinct = precinct.replace("LA P", "La P")' \
	-o $@

# Bath 2 merged into Bath 1
# https://www.elections.il.gov/precinctmaps/Mason/Mason%20County%20Voting%20Precinct%20Map.pdf
data/precincts/mason.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "125"' \
	-each 'precinct = ["ALLENS GROVE 1", "KILBOURNE 1"].includes(precinct) ? precinct.replace(" 1", "") : precinct.replace("BATH 2", "BATH 1")' \
	-dissolve2 precinct \
	-o $@

data/precincts/massac.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "127"' \
	-each 'precinct = precinct.includes("METROPOLIS") ? precinct : precinct.replace(/ \d+$$/g, "")' \
	-o $@

data/precincts/mcdonough.geojson:
	pipenv run python scripts/scrape_mcdonough.py | \
	mapshaper -i - \
	-proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-90.16666666666667 +k=0.999941 +x_0=700000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 \
	-each 'precinct = Name.toUpperCase().replace("MACOMB", "MACOMB TWP").replace("MC ", "MACOMB CITY ")' \
	-each 'precinct = precinct.replace(/(?<=MACOMB CITY) (?=\d$$)/g, " 0")' \
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
	-each 'precinct = Name.toUpperCase().replace("ATHENS ", "ATHENS-")' \
	-o $@

data/precincts/mercer.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "131"' -o $@

data/precincts/monroe.geojson:
	pipenv run esri2geojson https://services.arcgis.com/AZVIEb4WFZST2UYx/arcgis/rest/services/Voter_Precincts/FeatureServer/0 - | \
	mapshaper -i - \
	-each 'precinct = "PRECINCT " + PRECINCT.toString()' \
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
	mapshaper -i - \
	-proj init=webmercator crs=wgs84 \
	-rename-fields precinct=Precinct \
	-each 'precinct = precinct.toUpperCase().replace("/", "-")' \
	-each 'precinct = ["JACKSONVILLE", "MEREDOSIA", "WAVERLY"].some((s) => precinct.includes(s)) ? precinct.replace(/ (?=\d$$)/g, " 0"): precinct' \
	-each 'precinct = precinct.replace("SJA", "S JACKSONVILLE")' \
	-o $@

data/precincts/moultrie.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/MoultrieIL/MoultrieIL_PAT_Basemap_WM/MapServer/7 - | \
	mapshaper -i - \
	-each 'precinct = District.replace(/(?=\d)/g, " #").replace(/(?<=[a-z])(?=[A-Z])/g, " ").toUpperCase()' \
	-each 'precinct = precinct.match(/\d/g) ? precinct : precinct + " #1"' \
	-o $@

data/precincts/ogle.geojson:
	pipenv run python scripts/pybeacondump.py 'https://beacon.schneidercorp.com/Application.aspx?AppID=71&LayerID=592&PageTypeID=1&PageID=953' 5178 - | \
	mapshaper -i - \
	-proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-90.16666666666667 +k=0.999941 +x_0=700000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 \
	-dissolve2 precinct \
	-each 'precinct = precinct.toUpperCase().replace(".", "")' \
	-each 'precinct = ["BUFFALO", "BYRON", "FLAGG", "FORRESTON", "MARION", "MORRIS", "OREGON", "ROCKVALE"].some((s) => precinct.includes(s)) ? precinct : precinct.replace(" 1", "")' \
	-o $@

data/precincts/peoria.geojson:
	pipenv run esri2geojson https://services.arcgis.com/iPiPjILCMYxPZWTc/arcgis/rest/services/Voting_Precincts/FeatureServer/0 - | \
	mapshaper -i - -rename-fields precinct=NAME -o $@

data/precincts/perry.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "145"' \
	-each 'precinct = precinct.replace("DU QUOIN", "DUQUOIN")' \
	-each 'precinct = precinct.includes("DUQUOIN") ? precinct.replace(/ (?=\d$$)/g, " 0") : precinct' \
	-o $@

data/precincts/piatt.geojson:
	pipenv run esri2geojson --proxy https://services.ccgisc.org/proxy/proxy.ashx? https://services.ccgisc.org/server2/rest/services/Piatt_CountyClerk/Precincts/MapServer/0 - | \
	mapshaper -i - \
	-rename-fields precinct=Precinct \
	-each 'precinct = precinct.toUpperCase().replace("GORDO1", "GORDO 1")' \
	-o $@

data/precincts/pike.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "149"' \
	-each 'precinct = precinct.replace("MARTINSBURG 1", "MARTINSBURG")' \
	-o $@

data/precincts/pope.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< -filter 'COUNTYFP === "151"' -o $@

data/precincts/pulaski.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "153"' \
	-each 'precinct = precinct.replace("CITY 2", "CITY").replace("DGE - A", "DGE-A")' \
	-o $@

data/precincts/putnam.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "155"' \
	-each 'precinct = precinct.replace("-STANDARD", "").replace("-MARK", "").replace("-MCNABB", "")' \
	-each 'precinct = ["HENNEPIN", "SENACHWINE"].includes(precinct) ? precinct + " 1" : precinct' \
	-o $@

# TODO: Find Randolph Red Bud 5
data/precincts/randolph.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "157"' \
	-each 'precinct = precinct.replace(/-/gi, " ")' \
	-o $@

data/precincts/richland.geojson:
	pipenv run python scripts/scrape_richland.py | \
	mapshaper -i - \
	-clean rewind \
	-each 'precinct = precinct.replace(" Precinct", "").toUpperCase()' \
	-each 'precinct = precinct.includes("OLNEY") ? precinct.replace(/ (?=\d$$)/g, " 0") : precinct' \
	-o $@

data/precincts/rock-island.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "161"' \
	-each 'precinct = precinct.replace("SOUTH M", "SO M").replace("SOUTH R", "SO R")' \
	-o $@

data/precincts/saline.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "165"' \
	-each 'precinct = precinct.replace("ELDORADO", "EAST ELDORADO")' \
	-each 'precinct = ["COTTAGE 1", "GALATIA 1", "INDEPENDENCE 1", "LONG BRANCH 1", "MOUNTAIN 1", "RALEIGH 1", "RECTOR 1", "STONEFORT 1", "TATE 1"].includes(precinct) ? precinct.replace(" 1", "") : precinct' \
	-o $@

data/precincts/sangamon.geojson:
	pipenv run esri2geojson https://services.arcgis.com/XqG0RpqsNfIBGGb2/ArcGIS/rest/services/ElectionPollingAndPrecincts/FeatureServer/1 - | \
	mapshaper -i - -rename-fields precinct=NAME -o $@

data/precincts/schuyler.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "169"' \
	-each 'precinct = precinct.replace("FREDRICK", "FREDERICK")' \
	-o $@

data/precincts/scott.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "171"' \
	-each 'precinct = precinct.replace("WINCHESTER I", "WINCHESTER   I").replace("WINCHESTER II", "WINCHESTER  II")' \
	-o $@

data/precincts/shelby.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "173"' \
	-each 'precinct = precinct.replace("TOWER HILL", "TOWER HILL 1")' \
	-o $@

data/precincts/st-clair.geojson: input/precincts/st-clair.geojson
	mapshaper -i $< \
	-filter '!prec_name1.includes("East St")' \
	-rename-fields precinct=prec_name2 \
	-each 'precinct = precinct.replace("Ofallon", "O Fallon").replace("  ", " ")' \
	-o $@

input/precincts/st-clair.geojson:
	pipenv run esri2geojson https://publicmap01.co.st-clair.il.us/arcgis/rest/services/SCC_voting_district/MapServer/7 $@

data/precincts/stark.geojson: input/precincts/stark.geojson
	mapshaper -i $< \
	-each 'precinct = name.toUpperCase()' \
	-o $@

input/precincts/stark.geojson: input/precincts/stark.kml
	pipenv run k2g $< $(dir $@)

input/precincts/stark.kml:
	wget -O $@ 'https://www.google.com/maps/d/kml?mid=1T0Iz1DogKirf-ZbEfFlFoIRSAxY&lid=_WnUNJnJuT8&forcekml=1'

data/precincts/stephenson.geojson: input/precincts/County_Precincts_2010_Census.shp
	mapshaper -i $< \
	-proj wgs84 \
	-each 'precinct = TOWNSHIP_N + " " + +PRECINCT_N' \
	-each 'precinct = ["BUCKEYE 1", "DAKOTA 1", "ERIN 1", "FLORENCE 1", "JEFFERSON 1", "KENT 1", "LANCASTER 1", "LORAN 1", "ONECO 1", "RIDOTT 1", "ROCK GROVE 1", "SILVER CREEK 1", "WINSLOW 1"].includes(precinct) ? precinct.replace(" 1", "") : precinct' \
	-o $@

# Pulled from site manually, but included because uses strict firewall for automated downloads
input/precincts/County_Precincts_2010_Census.shp: input/foia/County_Precincts_2010_Census.zip
	unzip -u $< -d $(dir $@)

data/precincts/tazewell.geojson:
	pipenv run esri2geojson https://gis.tazewell.com/maps/rest/services/ElectionPoll/ElectionPollingPlaces/MapServer/1 - | \
	mapshaper -i - \
	-each 'precinct = NAME.toUpperCase().replace(" 0", " ").replace("BOYTON 1", "BOYNTON").replace("DEERCREEK 1", "DEER CREEK").replace("DILLON 1", "DILLON").replace("HITTLE 1", "HITTLE").replace("MALONE 1", "MALONE").replace("LITTLE ", "LT ")' \
	-o $@

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
	mapshaper -i $< \
	-filter 'COUNTYFP === "187"' \
	-each 'precinct = precinct.includes("MONMOUTH") ? precinct.replace(/ (?=\d$$)/g, "  ") : precinct' \
	-each 'precinct = precinct.match(/\d/g) ? precinct : precinct + " 1"' \
	-each 'precinct = precinct.replace("GERLAW 1", "GERLAW 2")' \
	-o $@

# Nashville 2 consolidated in 1, Irvington consolidated
# https://www.elections.il.gov/precinctmaps/Washington/Washington%20County%20Precinct%20Map.pdf
data/precincts/washington.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "189"' \
	-each 'precinct = precinct.replace("DUBOIS", "DuBOIS").replace("NASHVILLE 2", "NASHVILLE 1").replace("IRVINGTON 2", "IRVINGTON 1")' \
	-each 'precinct = ["ASHLEY 1", "IRVINGTON 1", "OAKDALE 1", "VENEDY 1"].includes(precinct) ? precinct.replace(" 1", "") : precinct' \
	-dissolve2 precinct \
	-o $@

data/precincts/wayne.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "191"' \
	-each 'precinct = precinct.replace(" TWP", "").replace("GROVER/", "").replace(" PCT", "").replace("MT ", "MT. ").replace("GOLDEN ", "GOLDEN")' \
	-o $@

data/precincts/white.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "193"' \
	-each 'precinct = precinct.replace("HAROLDS", "HERALDS")' \
	-o $@

data/precincts/whiteside.geojson:
	pipenv run esri2geojson https://services.arcgis.com/l0M0OC6J9QAHCiGx/ArcGIS/rest/services/ElectionGeography_public/FeatureServer/1 - | \
	mapshaper -i - \
	-rename-fields precinct=name \
	-each 'precinct = precinct.toUpperCase().replace("MT ", "MT. ")' \
	-each 'precinct = precinct.match(/\d/g) ? precinct : precinct + " 1"' \
	-o $@

data/precincts/will.geojson:
	pipenv run esri2geojson https://gis.willcountyillinois.com/hosting/rest/services/PoliticalLayers/Precincts/MapServer/0 - | \
	mapshaper -i - \
	-each 'precinct = NAME.replace("DUPAGE", "DU PAGE")' \
	-o $@

data/precincts/williamson.geojson: input/precincts/il_2016.geojson
	mapshaper -i $< \
	-filter 'COUNTYFP === "199"' \
	-each 'precinct = precinct.replace(" TWP", "").replace("CORINTH", "CORINTH 1").replace("GRASSY", "GRASSY 1").replace("EM09 EAST MARION", "EAST MARION 9").replace("EM10 EAST MARION", "EAST MARION 10")' \
	-o $@

# Cherry Valley 12, Cherry Valley 9, Harlem 18, Harlem 4
# Cherry Valley 12 merged into 1
# Cherry Valley 9 merged into 4
# Harlem 18 merged into 16
# Harlem 4 merged into 19
data/precincts/winnebago.geojson: input/precincts/Shapefiles_2020.shp
	mapshaper -i $< \
	-proj crs=wgs84 \
	-each 'precinct = PCTNAME.toUpperCase().replace(/\s+/, " ").replace("ROCKTON1", "ROCKTON 1").replace("ROCKFORD ROCKFORD", "ROCKFORD")' \
	-dissolve2 precinct \
	-o $@

input/precincts/Shapefiles_2020.shp: input/foia/Shapefiles_2020.zip
	unzip -u $< -d $(dir $@)

data/precincts/woodford.geojson:
	pipenv run esri2geojson https://services.arcgis.com/pPTAs43AFhhk0pXQ/ArcGIS/rest/services/WoodfordCounty_Election_Polling_Places/FeatureServer/1 - | \
	mapshaper -i - \
	-each 'precinct = Precinct_N.toUpperCase()' \
	-o $@

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
	-each 'precinct = "Ward " + WARD.toString().padStart(2, "0") + " Precinct " + precinct_num.toString().padStart(2, "0")' \
	-o $@

input/precincts/city-of-chicago-wards.geojson:
	wget -O $@ 'https://data.cityofchicago.org/api/geospatial/sp34-6z76?method=export&format=GeoJSON'

data/precincts/city-of-danville.geojson:
	pipenv run esri2geojson https://utility.arcgis.com/usrsvcs/servers/463571faad874d958bcf15661f49f25c/rest/services/Administrative/Voting_Precincts/MapServer/1 - | \
	mapshaper -i - \
	-rename-fields precinct=Precinct \
	-each 'precinct = "PRECINCT " + precinct' \
	-o $@

data/precincts/city-of-east-st-louis.geojson: input/precincts/st-clair.geojson
	mapshaper -i $< \
	-filter 'prec_name1.includes("East St")' \
	-rename-fields precinct=prec_name2 \
	-each 'precinct = precinct.replace("East St Louis", "PRECINCT").replace(/ (?=\d$$)/g, " 0")' \
	-o $@

data/precincts/city-of-galesburg.geojson: input/precincts/Galesburg_City_Council_Wards.shp
	mapshaper -i $< \
	-each 'precinct = "PRECINCT " + PRECINCT.toString()' \
	-o $@

input/precincts/Galesburg_City_Council_Wards.shp: input/precincts/city-of-galesburg.zip
	unzip -u $< -d $(dir $@)

input/precincts/city-of-galesburg.zip:
	wget -O $@ https://opendata.arcgis.com/datasets/5c909cb0bf8b41d4926e0464645bc2e2_0.zip

# TODO: Missing 1404
data/precincts/city-of-rockford.geojson:
	pipenv run python scripts/scrape_clarity.py https://results.enr.clarityelections.com/WRC/Rockford/107126/270015/json/3a6d9b2e-0e2b-467c-9450-d30f9bd379ee.json "city-of-rockford" | \
	mapshaper -i - \
	-rename-fields precinct=Name \
	-dissolve2 precinct \
	-each 'precinct = "WARD " + (+precinct.slice(0, 2)) + " PRECINCT " + (+precinct.slice(2))' \
	-o $@

input/precincts/il_2016.geojson: input/precincts/il_2016.shp
	mapshaper -i $< -proj wgs84 -filter-fields COUNTYFP,NAME -rename-fields precinct=NAME -o $@

input/precincts/il_2016.shp: input/precincts/il_2016.zip
	unzip -u $< -d $(dir $@)

# Citation guidelines https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/NH5S2I/IJPOUH&version=46.0
# https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/NH5S2I/A652IT&version=46.0
input/precincts/il_2016.zip:
	wget -O $@ 'https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/NH5S2I/IJPOUH'

data/results/cass.csv: input/results/il-2020.csv
	xsv search -s authority '^cass$$' $< | \
	mapshaper -i - format=csv \
	-each 'precinct = precinct.replace(/\D/g, "")' \
	-o $@

data/results/franklin.csv: input/results/il-2020.csv
	xsv search -s authority '^franklin$$' $< | \
	mapshaper -i - format=csv \
	-each 'precinct = precinct.toUpperCase()' \
	-o $@

data/results/lake.csv: input/results/il-2020.csv
	xsv search -s authority '^lake$$' $< | \
	mapshaper -i - format=csv \
	-each 'precinct = precinct.split(" ").slice(-1)[0]' \
	-o $@

data/results/marion.csv: input/results/il-2020.csv
	xsv search -s authority '^marion$$' $< | \
	mapshaper -i - format=csv \
	-each 'precinct = precinct.toUpperCase()' \
	-o $@

# TODO: Can't confirm this works without final results
data/results/%.csv: input/results/il-2020.csv
	xsv search -s authority '^$*$$' $< > $@

input/results/il-2020.csv: input/results/us-president.csv input/results/us-senate.csv
	xsv cat rows $^ | \
	pipenv run python scripts/process_boe_results.py > $@

# TODO: Placeholders, might end up being same URL
input/results/us-president.csv:
	wget -O $@ 'https://www.elections.il.gov/Downloads/ElectionOperations/ElectionResults/ByOffice/51/51-120-PRESIDENT%20AND%20VICE%20PRESIDENT-2016GE.csv'

input/results/us-senate.csv:
	wget -O $@ 'https://www.elections.il.gov/Downloads/ElectionOperations/ElectionResults/ByOffice/51/51-160-UNITED%20STATES%20SENATOR-2016GE.csv'

input/results/il-constitution.csv:
	wget -O $@ 'https://www.elections.il.gov/Downloads/ElectionOperations/ElectionResults/ByOffice/58/58-100-1A-1-2016GE.csv'
