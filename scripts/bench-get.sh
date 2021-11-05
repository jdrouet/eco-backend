#!/bin/bash

set +x

PORT=3000

./bin/hey -n $2 -c $3 http://127.0.0.1:$PORT/

