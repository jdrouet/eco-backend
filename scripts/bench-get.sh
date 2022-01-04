#!/bin/bash

set +x

PORT=3000

# ./bin/hey -n 1000000 -c $1 http://127.0.0.1:$PORT/
./bin/hey -z 10m -c $1 http://127.0.0.1:$PORT/

