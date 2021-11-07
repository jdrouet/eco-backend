#!/bin/bash

set -e

rm -rf results/$1
mkdir -p results/$1

docker-compose up -d blackhole

echo "# doing a dry build to load images in cache"
docker-compose build $1

echo "# building $1"

./bin/joule ./scripts/build.sh $1 > results/$1/build.txt

echo "# start logging activity"
docker-compose up -d activity

sleep 2

echo "# starting $1"
./scripts/start.sh $1 > results/$1/start.txt

sleep 2

echo "# benchmarking $1"

./scripts/bench-get.sh $1 > results/$1/bench-get.txt

sleep 2

./scripts/bench-post.sh $1 >> results/$1/bench-post.txt

sleep 2

docker-compose stop $1
docker-compose rm -f $1

docker-compose stop activity
docker-compose rm -f activity

docker-compose stop blackhole
docker-compose rm -f blackhole

echo "# waiting for the system to relax..."
sleep 10
