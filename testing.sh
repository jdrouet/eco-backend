#!/bin/bash

# set -x

PORT=3000

function download_binaries() {
	echo "# downloading joule binary"
	curl -L -o bin/joule https://github.com/jdrouet/joule/releases/download/0.1.0/joule-0.1.0
	echo "# downloading hey binary"
	curl -L -o bin/hey https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
}

function cleanup() {
	echo "# doing some cleanup..."
	docker rm -f $(docker ps -aq) &> /dev/null
}

function wait_for_server() {
	echo "# waiting for server"
	start_date=$(date +"%s")
	while :; do
		curl http://localhost:$PORT/ &> /dev/null
		if [ $? -eq 0 ]; then
			break
		fi
	done
	end_date=$(date +"%s")
	diff_date=$(($end_date-$start_date))
	echo "# server $1 took $diff_date seconds to start" 
	echo "boot,$1,$diff_date" >> timing.csv
}

function test_server() {
	echo "# starting the database..."
	docker-compose up -d database
	sleep 5
	echo "# build and start the server..."
	./bin/joule snapshot results/$1-starting-before.json
	docker-compose up --build -d $1
	wait_for_server $1
	./bin/joule snapshot results/$1-starting-after.json
	echo "# publishing some logs..."
	for i in {0..10}; do
		createdAt=$(echo $i + 1633462963 | bc)
		curl -X POST -H "Content-type: Application/json" \
			--data "[{\"createdAt\":$createdAt,\"level\":\"info\",\"message\":\"hello world\",\"index\":$i}]" \
			http://localhost:$PORT/publish
	done
	echo "# searching for logs..."
	curl http://localhost:$PORT/search &> /dev/null
	echo
	cleanup
}

cleanup
test_server "golang"
test_server "java"
test_server "nodejs"
test_server "php"
test_server "python"
test_server "rust"

