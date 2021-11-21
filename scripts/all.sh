#!/bin/bash

for name in golang java-springboot nodejs-express php-laravel python-flask rust-actix; do
	./scripts/run.sh $name
done
