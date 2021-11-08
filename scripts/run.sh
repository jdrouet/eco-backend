#!/bin/bash

set -e

name=$1

mkdir -p results
rm -rf results/$name-*

docker-compose up -d blackhole

echo "# doing a dry build to load images in cache"
docker-compose build $name

echo "# building $name"
./bin/joule ./scripts/build.sh $name > results/$name-build.txt

sleep 2

for method in get post; do
	for concurrency in 1 2 3 5 8 13 21 34 55; do
		echo "# start logging activity"
		docker-compose up -d activity

		echo "# starting $name"
		./scripts/start.sh $name
		sleep 1

		echo "# benchmarking $name - $concurrency $method"
		sleep 2
		./scripts/bench-$method.sh $name $concurrency > results/$name-bench-$method-$concurrency.txt
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
