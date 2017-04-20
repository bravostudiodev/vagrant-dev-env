prep:
	pachctl version
	cd citibike_data && ./load.sh
	cd weather_data && ./load.sh
	pachctl create-pipeline -f ./sales-pipeline.json

launch-jupyter:
	./pachy-jupy.sh
	
clean-launch:
	pachctl delete-repo trips
	pachctl delete-repo weather
	pachctl delete-repo sales
