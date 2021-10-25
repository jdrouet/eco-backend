#!/bin/bash

set -x

function cleanup() {
	echo "# doing some cleanup..."
	docker rm -f $(docker ps -aq)
}

function wait_for_server() {
	echo "# waiting for server on port $1"
	curl http://localhost:$1/
	if [ $? -eq 0 ]; then
		echo "# server seems to be ready..."
	else
		sleep 1
		wait_for_server $1
	fi
}

function test_server() {
	echo "# starting the database..."
	docker-compose up -d database
	sleep 5
	echo "# build and start the server..."
	docker-compose up --build -d $1
	wait_for_server $2
	echo "# publishing some logs..."
	for i in {0..10}; do
		createdAt=$(echo $i + 1633462963 | bc)
		curl -X POST -H "Content-type: Application/json" \
			--data "[{\"createdAt\":$createdAt,\"level\":\"info\",\"message\":\"hello world\",\"index\":$i}]" \
			http://localhost:$2/publish
	done
	echo "# searching for logs..."
	curl http://localhost:$2/search
	cleanup
}

cleanup
test_server "golang" 8080
test_server "java" 8080
test_server "nodejs" 3000
test_server "php" 8000
test_server "python" 5000
test_server "rust" 3000

