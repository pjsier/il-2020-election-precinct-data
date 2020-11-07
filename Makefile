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

data/precincts/cook.geojson:
	pipenv run esri2geojson https://gis12.cookcountyil.gov/arcgis/rest/services/electionSrvcLite/MapServer/1 $@

data/precincts/champaign.geojson:
	pipenv run esri2geojson --proxy https://services.ccgisc.org/proxy/proxy.ashx? https://services.ccgisc.org/server/rest/services/CountyClerk/Precincts/MapServer/0 $@

# data/precincts/christian.geojson:
# 	pipenv run esri2geojson https://services.arcgis.com/Xn3XOQd1zDlYr9z7/ArcGIS/rest/services/ElectoralDistricts/FeatureServer/1 $@

# data/precincts/coles.geojson:
# 	pipenv run esri2geojson https://www.co.coles.il.us/ccwgis/rest/services/CountyClerk/VoterPrecincts/MapServer/1 $@

data/precincts/dupage.geojson:
	pipenv run esri2geojson https://gis.dupageco.org/arcgis/rest/services/Elections/ElectionPrecincts/MapServer/0 $@

data/precincts/grundy.geojson:
	pipenv run esri2geojson https://maps.grundyco.org/arcgis/rest/services/CountyClerk/PollingPlaces_SPIE_Public/FeatureServer/1 $@

data/precincts/iroquois.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/IroquoisIL/IroquoisIL_PAT_GIS/MapServer/8 $@

data/precincts/lake.geojson:
	pipenv run esri2geojson https://maps.lakecountyil.gov/arcgis/rest/services/GISMapping/WABPoliticalBoundaries/MapServer/5 $@

data/precincts/lee.geojson:
	pipenv run esri2geojson https://gis.leecountyil.com/server/rest/services/Election/Election_Precincts/MapServer/0 $@

data/precincts/macon.geojson:
	pipenv run esri2geojson https://services1.arcgis.com/a3k0qIja5SolIRYR/ArcGIS/rest/services/ElectionGeography_public/FeatureServer/1 $@

data/precincts/macoupin.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/MacoupinIL/MacoupinIL_PAT_GIS/MapServer/4 $@

data/precincts/mchenry.geojson:
	pipenv run esri2geojson https://www.mchenrycountygis.org/arcgis/rest/services/County_Board/Precincts/MapServer/0 $@

data/precincts/menard.geojson: scripts/pybeacondump.py
	pipenv run python $< 'https://beacon.schneidercorp.com/api/beaconCore/GetVectorLayer?QPS=fAEOE9XHqspGGt-XzOAubrTzxnSLO1n6du498UaeWnCNnZ0NLSHJpGpfEiorTiHOgUc5iKXs22dpQuXHA4vyQlrVXW2YpVF_CSFOZiZjYTebiEYJmqusfbarDBl8gFV3Qd1Ef04En5OKzqwupstD3coQucMdfmenYU-NAPyFq90my7E29eSsIOI8zcXbcpJWaXcEplzc04YpQyddz2AVMmCj2FZLzgZuRv4dD36ZlLi0SeJ5Vblm9_0zQhjhuYqLfZAgfSyxoiJcCkkTdmH2Eg2' 25751 $@

data/precincts/montgomery.geojson: scripts/pybeacondump.py
	pipenv run python $< 'https://beacon.schneidercorp.com/api/beaconCore/GetVectorLayer?QPS=O9Vc5lNEg8Oh_TR60f60t8abmnzMwqDNWnUIRYFRx4AQbXvqOjy2f1l8ZM5tdcZfb4L5H2tNCMty9jxDoJg8kbYZY7O-VYQUZWnhwwqKQjVuk8nD-kdxb_aOoc7X_bJaIuh7VTFL3rZsZhiU5O4gYbMyOlN1GF4Q_PqwhbzvGD3nUahXCxaiuIyc_fKMfXuvdElxVbZZ82qU5HlL6a09ozeNivxPQNNKLkGvmGGkXhYIPBMQo4AlMJfCv2nnL0MpLmYKlZPPIZUPyTdjCKv3tQ2' 7705 $@

data/precincts/peoria.geojson:
	pipenv run esri2geojson https://gis.peoriacounty.org/arcgis/rest/services/DP/Elections/MapServer/8 $@

data/precincts/piatt.geojson:
	pipenv run esri2geojson --proxy https://services.ccgisc.org/proxy/proxy.ashx? https://services.ccgisc.org/server2/rest/services/Piatt_CountyClerk/Precincts/MapServer/0 $@

data/precincts/vermillion.geojson:
	pipenv run esri2geojson https://ags.bhamaps.com/arcgisserver/rest/services/VermilionIL/VermilionIL_PAT_GIS/MapServer/12 $@

data/precincts/whiteside.geojson:
	pipenv run esri2geojson https://services.arcgis.com/l0M0OC6J9QAHCiGx/ArcGIS/rest/services/ElectionGeography_public/FeatureServer/1 $@

data/precincts/will.geojson:
	pipenv run esri2geojson https://gis.willcountyillinois.com/arcgis/rest/services/PoliticalLayers/Precincts/MapServer/0 $@

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
