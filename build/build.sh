#!/bin/bash
DOCKERIMAGE="docker.io/golang:1.9.2"
PROJECT="github.com/Ppamo/go.noisy"
APPNAME=noisy
DST="src/github.com/Ppamo/go.noisy/bin/$APPNAME"
CMD="CGO_ENABLED=0 GOOS=linux go build -v -a -installsuffix cgo -o $DST $PROJECT"

# setup golang path to avoid selinux issues
which chcon > /dev/null 2>&1
if [ $? -eq 0 ]
then
	chcon -Rt svirt_sandbox_file_t $GOPATH
fi

docker run --rm --privileged=true -ti -v "$GOPATH:/go" "$DOCKERIMAGE" /bin/bash -c "$CMD"
