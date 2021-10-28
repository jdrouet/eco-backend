#!/bin/bash

# set -x

PORT=3000

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
	docker-compose up --build -d $1
	wait_for_server $1
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

