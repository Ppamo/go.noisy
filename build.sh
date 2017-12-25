#!/bin/bash
DOCKERIMAGE="${DOCKERIMAGE:-docker.io/golang:1.9.2}"
SRC=$1
DST=$2

CMD="CGO_ENABLED=0 GOOS=linux go build -v -a -installsuffix cgo -o \"$DST\" \"$SRC\""

which chcon > /dev/null 2>&1
if [ $? -eq 0 ]
then
	chcon -Rt svirt_sandbox_file_t $GOPATH
fi

docker run --rm --privileged=true -ti -v "$GOPATH:/go" "$DOCKERIMAGE" /bin/bash -c "$CMD"
