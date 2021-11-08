#!/bin/bash

for name in golang java nodejs php python rust; do
	./scripts/run.sh $name
done
