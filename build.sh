#!/bin/bash

VERSION=0.1.0
BINARYFILE=docker/noisy
DOMAIN=ppamo.cl
APPNAME=noisy
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m'

rm -f $BINARYFILE

printf "${ORANGE}* Building noisy ${NC}\n"
go get && CGO_ENABLED=0 GOOS=linux go build -v -a -installsuffix cgo -o $BINARYFILE .

if [ $? -eq 0 ]
then
	if [ -x $BINARYFILE ]
	then
		VERSION=$(docker images | grep "$DOMAIN/$APPNAME" | awk '{ print $2 }')
		if [ "$VERSION" ]
		then
			printf "${ORANGE}* Deleting image $DOMAIN/$APPNAME:$VERSION ${NC}\n"
			docker rmi $DOMAIN/$APPNAME:$VERSION
		fi
		TAGVERSION=$(git tag | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$" | tail -n 1)
		if [ "$TAGVERSION" ]
		then
			PATCHNUMBER=$(echo "$TAGVERSION" | grep -Eo "[0-9]+$")
			VERSION=${TAGVERSION%$PATCHNUMBER}$((PATCHNUMBER+1))
		fi
		printf "${ORANGE}* Building docker image $DOMAIN/$APPNAME:$VERSION ${NC}\n"
		docker build -t $DOMAIN/$APPNAME:$VERSION docker/
		IMAGESNUMBER=$(docker images $DOMAIN/$APPNAME:$VERSION --format "{{.ID}}" | wc -l)
		if [ $IMAGESNUMBER -gt 0 ]
		then
			printf "${ORANGE}* Running container ${NC}\n"
			docker run --rm=true -ti $DOMAIN/$APPNAME:$VERSION
		fi
		exit 0
	fi
fi
printf  "${RED}* Build iled!!${NC}\n"
exit 1
