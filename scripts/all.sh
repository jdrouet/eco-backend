#!/bin/bash

set -e

rm -rf results/$1
mkdir -p results/$1

docker-compose up -d blackhole

echo "# doing a dry build to load images in cache"
docker-compose build $1

echo "# executing script for $1"

./bin/joule ./scripts/build.sh $1 > results/$1/build.txt

./bin/joule ./scripts/start.sh $1 > results/$1/start.txt

./bin/joule ./scripts/bench-get.sh $1 10000 20 > results/$1/bench.txt
./bin/joule ./scripts/bench-get.sh $1 10000 50 >> results/$1/bench.txt
./bin/joule ./scripts/bench-get.sh $1 1000000 20 >> results/$1/bench.txt
./bin/joule ./scripts/bench-get.sh $1 1000000 50 >> results/$1/bench.txt

./bin/joule ./scripts/bench-post.sh $1 10000 20 >> results/$1/bench.txt
./bin/joule ./scripts/bench-post.sh $1 10000 50 >> results/$1/bench.txt
./bin/joule ./scripts/bench-post.sh $1 1000000 20 >> results/$1/bench.txt
./bin/joule ./scripts/bench-post.sh $1 1000000 50 >> results/$1/bench.txt

docker-compose stop $1
docker-compose rm -f $1

docker-compose stop blackhole
docker-compose rm -f blackhole

echo "# waiting for the system to relax..."
sleep 10
