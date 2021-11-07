#!/bin/bash

set +x

PORT=3000

./bin/hey -n 1000000 -c 50 http://127.0.0.1:$PORT/

