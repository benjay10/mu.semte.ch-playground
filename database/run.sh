#!/bin/bash

docker run \
    --name virtuosodatabase \
	--interactive \
	--tty \
	--env DBA_PASSWORD=toegang \
	--env SPARQL_UPDATE=true \
	--env DEFAULT_GRAPH=http://www.example.com/my-graph \
	--volume `pwd`/data:/data:Z \
    --publish 1111:1111 \
    --publish  8890:8890 \
	redpencil/virtuoso

#	tenforce/virtuoso


