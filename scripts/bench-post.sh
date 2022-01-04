#!/bin/bash

set +x

PORT=3000

# ./bin/hey -n 1000000 -c $1 -D scripts/data.json -T "application/json" -m POST http://127.0.0.1:$PORT/publish
./bin/hey -z 10m -c $1 -D scripts/data.json -T "application/json" -m POST http://127.0.0.1:$PORT/publish

