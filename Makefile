PRECINCT_FILES := $(shell cat input/jurisdictions.txt | xargs -I {} echo "data/precincts/{}.geojson")

all: $(PRECINCT_FILES)

.PHONY: clean
clean:
	rm -f data/precincts/*.* input/precincts/*.*

.PHONY: install
install:
	pipenv sync --dev

data/precincts/adams.geojson:
	pipenv run esri2geojson http://www.adamscountyarcserver.com/adamscountyarcserver/rest/services/AdamsCoBaseMapFG_2018/MapServer/43 $@

data/precincts/boone.geojson:
	pipenv run esri2geojson https://maps.boonecountyil.org/arcgis/rest/services/Clerk_and_Recorder/Voting_Polling_Places/MapServer/1 $@

data/precincts/cass.geojson: scripts/pybeacondump.py
	pipenv run python $< 'https://beacon.schneidercorp.com/api/beaconCore/GetVectorLayer?QPS=5Y-f7mRUbGJaENB0Jltwx3G4KcI4w12v92cQJrmqo-vp6Ck-OC5Nthe73OFOi96NPQttpAccNgvzMxe1HII-pRLF3Xu3wh_wKPM-SWHbmTYJ4wYRn_cWh05VEFH4mTHSyrVQBgtZRaw3R1fdP6lMB4DX1BynJt-W6wSFiC3dnlZctHo5zM5bf-d6QNFExxGiuty5LTLlnq8V3KKcAqKBTyF9Oc7Vc6tOBn1SD5sjmjZF1KhztoKqZXtlBjWpIn4tw388hH3vUBiG4phR20rgVQ2' 1751 $@

data/precincts/champaign.geojson:
	pipenv run esri2geojson --proxy https://services.ccgisc.org/proxy/proxy.ashx? https://services.ccgisc.org/server/rest/services/CountyClerk/Precincts/MapServer/0 $@

data/precincts/coles.geojson:
	pipenv run python scripts/scrape_coles.py | \
	mapshaper -i - -proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-88.33333333333333 +k=0.999975 +x_0=300000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 -o $@

data/precincts/cook.geojson:
	pipenv run esri2geojson https://gis12.cookcountyil.gov/arcgis/rest/services/electionSrvcLite/MapServer/1 $@

data/precincts/dupage.geojson:
	pipenv run esri2geojson https://gis.dupageco.org/arcgis/rest/services/Elections/ElectionPrecincts/MapServer/0 $@

data/precincts/effingham.geojson:
	pipenv run esri2geojson https://services.arcgis.com/vj0V9Lal6oiz0YXp/ArcGIS/rest/services/ElectoralDistricts/FeatureServer/1 $@

data/precincts/grundy.geojson:
	pipenv run esri2geojson https://maps.grundyco.org/arcgis/rest/services/CountyClerk/PollingPlaces_SPIE_Public/FeatureServer/1 $@

data/precincts/iroquois.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/IroquoisIL/IroquoisIL_PAT_GIS/MapServer/8 $@

data/precincts/kankakee.geojson:
	pipenv run esri2geojson https://k3gis.com/arcgis/rest/services/BASE/Elected_Officials/MapServer/0 $@

data/precincts/kendall.geojson: input/precincts/Kendall_County_Voting_Precinct.shp
	mapshaper -i $< -o $@

input/precincts/Kendall_County_Voting_Precinct.shp: input/precincts/kendall.zip
	unzip -u $< -d $(dir $@)

input/precincts/kendall.zip:
	wget -O $@ 'https://opendata.arcgis.com/datasets/bc2430d057cb487aa51273e4e8762c2e_0.zip?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D'

data/precincts/lake.geojson:
	pipenv run esri2geojson https://maps.lakecountyil.gov/arcgis/rest/services/GISMapping/WABPoliticalBoundaries/MapServer/5 $@

data/precincts/lee.geojson:
	pipenv run esri2geojson https://gis.leecountyil.com/server/rest/services/Election/Election_Precincts/MapServer/0 $@

data/precincts/logan.geojson:
	pipenv run esri2geojson https://www.centralilmaps.com/arcgis/rest/services/Logan/Logan_Flex_1/MapServer/40 $@

data/precincts/macon.geojson:
	pipenv run esri2geojson https://services1.arcgis.com/a3k0qIja5SolIRYR/ArcGIS/rest/services/ElectionGeography_public/FeatureServer/1 $@

data/precincts/macoupin.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/MacoupinIL/MacoupinIL_PAT_GIS/MapServer/4 $@

data/precincts/madison.geojson:
	pipenv run esri2geojson --proxy https://gis.co.madison.il.us/proxy/proxy.ashx? --header Referer:'https://gis.co.madison.il.us/madco/viewer/index.html?config=Voter' https://gisportal.co.madison.il.us/servera/rest/services/CountyClerk/PrecinctsWS/MapServer/0 $@

data/precincts/mcdonough.geojson:
	pipenv run python scripts/scrape_mcdonough.py | \
	mapshaper -i - -proj init='+proj=tmerc +lat_0=36.66666666666666 +lon_0=-90.16666666666667 +k=0.999941 +x_0=700000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' crs=wgs84 -o $@

data/precincts/mchenry.geojson:
	pipenv run esri2geojson https://www.mchenrycountygis.org/arcgis/rest/services/County_Board/Precincts/MapServer/0 $@

data/precincts/mclean.geojson:
	pipenv run esri2geojson https://gis.mcleancountyil.gov/arcgis/rest/services/Clerks/PollingPlaces/MapServer/1 $@

data/precincts/menard.geojson: scripts/pybeacondump.py
	pipenv run python $< 'https://beacon.schneidercorp.com/api/beaconCore/GetVectorLayer?QPS=fAEOE9XHqspGGt-XzOAubrTzxnSLO1n6du498UaeWnCNnZ0NLSHJpGpfEiorTiHOgUc5iKXs22dpQuXHA4vyQlrVXW2YpVF_CSFOZiZjYTebiEYJmqusfbarDBl8gFV3Qd1Ef04En5OKzqwupstD3coQucMdfmenYU-NAPyFq90my7E29eSsIOI8zcXbcpJWaXcEplzc04YpQyddz2AVMmCj2FZLzgZuRv4dD36ZlLi0SeJ5Vblm9_0zQhjhuYqLfZAgfSyxoiJcCkkTdmH2Eg2' 25751 $@

data/precincts/monroe.geojson:
	pipenv run esri2geojson https://services.arcgis.com/AZVIEb4WFZST2UYx/arcgis/rest/services/Voter_Precincts/FeatureServer/0 $@

data/precincts/montgomery.geojson: scripts/pybeacondump.py
	pipenv run python $< 'https://beacon.schneidercorp.com/api/beaconCore/GetVectorLayer?QPS=O9Vc5lNEg8Oh_TR60f60t8abmnzMwqDNWnUIRYFRx4AQbXvqOjy2f1l8ZM5tdcZfb4L5H2tNCMty9jxDoJg8kbYZY7O-VYQUZWnhwwqKQjVuk8nD-kdxb_aOoc7X_bJaIuh7VTFL3rZsZhiU5O4gYbMyOlN1GF4Q_PqwhbzvGD3nUahXCxaiuIyc_fKMfXuvdElxVbZZ82qU5HlL6a09ozeNivxPQNNKLkGvmGGkXhYIPBMQo4AlMJfCv2nnL0MpLmYKlZPPIZUPyTdjCKv3tQ2' 7705 $@

data/precincts/morgan.geojson:
	wget -qO - 'https://morganmaps.maps.arcgis.com/sharing/rest/content/items/8d7a6a2f54fa4686b6cbcfc47c6fb4d1/data?f=json' | \
	jq '.operationalLayers[0].featureCollection.layers[0].featureSet' | \
	pipenv run arcgis2geojson | \
	mapshaper -i - -proj init=webmercator crs=wgs84 -o $@

data/precincts/ogle.geojson: scripts/pybeacondump.py
	pipenv run python $< 'https://beacon.schneidercorp.com/api/beaconCore/GetVectorLayer?QPS=G6FoQaUZU4n-zot_iTSvAB4wv_cdXc45PwpSRkmeWSW358IAs6lDrCEC4ljJBm01d2tbzLyHKAtSlKyo_GszDLZt1laiburRnI1xJom-uYe5SXhkt6Ykf0_zGuI_NJiLUCbTc-D4fNuYPm90euvbJh-mxhaV_FWsGc6-0xoxEuUq5RJ9LKeF_zw5Sg2BdiWSj2qTUOnzjjqyza5hzyPRfjlWY0nF7E-8YOVGlA38ZAhmYUDyZPMlabB54odVRFGEYesyGeYae_21virTa9FE4A2' 5178 $@

data/precincts/peoria.geojson:
	pipenv run esri2geojson https://gis.peoriacounty.org/arcgis/rest/services/DP/Elections/MapServer/8 $@

data/precincts/piatt.geojson:
	pipenv run esri2geojson --proxy https://services.ccgisc.org/proxy/proxy.ashx? https://services.ccgisc.org/server2/rest/services/Piatt_CountyClerk/Precincts/MapServer/0 $@

data/precincts/sangamon.geojson:
	pipenv run esri2geojson https://services.arcgis.com/XqG0RpqsNfIBGGb2/ArcGIS/rest/services/ElectionPollingAndPrecincts/FeatureServer/1 $@

data/precincts/st-clair.geojson:
	pipenv run esri2geojson https://publicmap01.co.st-clair.il.us/arcgis/rest/services/SCC_voting_district/MapServer/7 $@

data/precincts/tazewell.geojson:
	pipenv run esri2geojson https://gis.tazewell.com/maps/rest/services/ElectionPoll/ElectionPollingPlaces/MapServer/1 $@

data/precincts/vermillion.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/VermilionIL/VermilionIL_PAT_GIS/MapServer/12 $@

data/precincts/whiteside.geojson:
	pipenv run esri2geojson https://services.arcgis.com/l0M0OC6J9QAHCiGx/ArcGIS/rest/services/ElectionGeography_public/FeatureServer/1 $@

data/precincts/will.geojson:
	pipenv run esri2geojson https://gis.willcountyillinois.com/arcgis/rest/services/PoliticalLayers/Precincts/MapServer/0 $@

data/precincts/woodford.geojson:
	pipenv run esri2geojson https://services.arcgis.com/pPTAs43AFhhk0pXQ/ArcGIS/rest/services/WoodfordCounty_Election_Polling_Places/FeatureServer/1 $@

data/precincts/city-of-bloomington.geojson: input/precincts/Voting_Precincts.shp
	mapshaper -i $< -o $@

input/precincts/Voting_Precincts.shp: input/precincts/city-of-bloomington.zip
	unzip -u $< -d $(dir $@)

input/precincts/city-of-bloomington.zip:
	wget -O $@ https://opendata.arcgis.com/datasets/bb22d15063da452587c82339cb7a3322_15.zip

data/precincts/city-of-chicago.geojson: input/precincts/city-of-chicago.geojson input/precincts/city-of-chicago-wards.geojson
	mapshaper -i $< -clip $(filter-out $<,$^) -o $@

input/precincts/city-of-chicago.geojson:
	wget -O $@ https://raw.githubusercontent.com/datamade/chicago-municipal-elections/master/precincts/2019_precincts.geojson

input/precincts/city-of-chicago-wards.geojson:
	wget -O $@ 'https://data.cityofchicago.org/api/geospatial/sp34-6z76?method=export&format=GeoJSON'

data/precincts/city-of-danville.geojson:
	pipenv run esri2geojson https://utility.arcgis.com/usrsvcs/servers/463571faad874d958bcf15661f49f25c/rest/services/Administrative/Voting_Precincts/MapServer/1 $@
