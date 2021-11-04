#!/bin/bash

set +x

PORT=3000

docker-compose up -d $1

while :; do
	curl http://localhost:$PORT/ &> /dev/null
	if [ $? -eq 0 ]; then
		break
	fi
done

