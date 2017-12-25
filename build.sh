#!/bin/bash

VERSION=0.1.0
BINARYFILE=docker/noisy
DOMAIN=ppamo.cl
APPNAME=noisy

rm -f $BINARYFILE

echo "* Building noisy"
go get && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o $BINARYFILE .

if [ $? -eq 0 ]
then
	if [ -x $BINARYFILE ]
	then
		VERSION=$(docker images | grep "$DOMAIN/$APPNAME" | awk '{ print $2 }')
		if [ "$VERSION" ]
		then
			echo "* Deleting image $DOMAIN/$APPNAME:$VERSION"
			docker rmi $DOMAIN/$APPNAME:$VERSION
		fi
		TAGVERSION=$(git tag | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$" | tail -n 1)
		if [ "$TAGVERSION" ]
		then
			PATCHNUMBER=$(echo "$TAGVERSION" | grep -Eo "[0-9]+$")
			VERSION=${TAGVERSION%$PATCHNUMBER}$((PATCHNUMBER+1))
		fi
		echo "* Building docker image $DOMAIN/$APPNAME:$VERSION"
		docker build -t $DOMAIN/$APPNAME:$VERSION docker/
		IMAGESNUMBER=$(docker images $DOMAIN/$APPNAME:$VERSION --format "{{.ID}}" | wc -l)
		if [ $IMAGESNUMBER -gt 0 ]
		then
			echo "* Running container"
			docker run --rm=true -ti $DOMAIN/$APPNAME:$VERSION
		fi
		exit 0
	fi
fi
echo "Filed!!"
exit 1
