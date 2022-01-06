#!/bin/bash

set -xe

make -p bin

echo "# downloading joule binary"
curl -L -o bin/joule https://github.com/jdrouet/joule/releases/download/0.2.0/joule-0.2.0
chmod +x bin/joule

echo "# downloading hey binary"
curl -L -o bin/hey https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
chmod +x bin/hey

