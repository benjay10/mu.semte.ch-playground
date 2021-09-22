#!/bin/bash

docker run \
	--name emberAppc \
	-i --tty \
	--volume `pwd`/webapp/:/webapp/ \
	--publish 4200:4200 \
	emberapp:latest

