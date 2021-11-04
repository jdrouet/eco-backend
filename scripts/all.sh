#!/bin/bash

set -e

for name in golang java nodejs php python rust; do

	mkdir -p results/$name

	docker-compose up -d database

	echo "# doing a dry build to load images in cache"
	docker-compose build $name

	echo "# executing script for $name"

	eco-spy --output results/$name/build.json "./scripts/build.sh $name"

	eco-spy --output results/$name/start.json "./scripts/start.sh $name"

	eco-spy --output results/$name/bench.json "./scripts/bench.sh $name"

	docker-compose stop $name
	docker-compose rm -f $name
	docker-compose stop database
	docker-compose rm -f database

	echo "# waiting for the system to relax..."
	sleep 10
done
