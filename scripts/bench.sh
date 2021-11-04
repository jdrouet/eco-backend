#!/bin/bash

set +x

PORT=3000

ab -r -n 1000000 -c 100 -p scripts/data.json -T "application/json" -m "POST" http://127.0.0.1:$PORT/publish > results/$1/bench-publish.txt

ab -r -n 1000000 -c 100 http://127.0.0.1:$PORT/search > results/$1/bench-search.txt

