#!/bin/bash
DOCKERIMAGE="${DOCKERIMAGE:-docker.io/golang:1.9.2}"
SRC=$1
DST=$2

CMD="cd \"src/$SRC\" && go get && CGO_ENABLED=0 GOOS=linux go build -v -a -installsuffix cgo -o \"$DST\" ."

OS=$(uname -o)
if [ "$OS" != "Cygwin" ]
then
	which chcon > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		chcon -Rt svirt_sandbox_file_t $GOPATH
	fi
fi

docker run --rm --privileged=true -i -v "$GOPATH:/go" "$DOCKERIMAGE" /bin/bash -c "$CMD"
