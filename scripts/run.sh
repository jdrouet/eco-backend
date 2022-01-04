#!/bin/bash

set -e

name=$1

mkdir -p results
rm -rf results/$name-*

docker-compose up -d blackhole

echo "# doing a dry build to load images in cache"
docker-compose build $name

echo "# building $name"
./bin/joule snapshot results/$name-build-before.json
./scripts/build.sh $name
./bin/joule snapshot results/$name-build-after.json

sleep 2

for method in get post; do
	for concurrency in 1 10 30 50; do
		echo "# starting activity watcher"
		docker-compose up -d activity
		sleep 2

		echo "# starting $name"
		./bin/joule snapshot results/$name-start-before.json
		./scripts/start.sh $name
		./bin/joule snapshot results/$name-start-after.json
		sleep 2

		echo "# benchmarking $name - $concurrency $method"
		./bin/joule snapshot results/$name-bench-$method-$concurrency-before.json
		./scripts/bench-$method.sh $concurrency > results/$name-bench-$method-$concurrency.txt
		./bin/joule snapshot results/$name-bench-$method-$concurrency-after.json
		sleep 2

		docker-compose stop $name
		docker-compose rm -f $name
		docker-compose stop activity
		docker-compose rm -f activity
		sleep 2

		mv results/output.csv results/$name-bench-$method-$concurrency.csv
	done
done

docker-compose stop blackhole
docker-compose rm -f blackhole

echo "# waiting for the system to relax..."
sleep 10
