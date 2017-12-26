#!/bin/bash

get_md5sum(){
	if [ -f "$1" ]
	then
		md5sum $1 | awk '{ print $1 }'
	fi
}

if [ -z "$GOPATH" ]
then
	echo "* GOPATH is not set!"
	exit -1
fi

FORCEIMAGEBUILD="${FORCEIMAGEBUILD:-0}"
VERSION=0.1.0
SRC="github.com/Ppamo/go.noisy"
DST="bin/noisy"
BINARYFILE="$GOPATH/src/$SRC/$DST"
IMAGENAME="ppamo.cl/noisy"
RED='\033[0;31m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
NC='\033[0m'

OS=$(uname -o)
if [ "$OS" == "Cygwin" ]
then
	BINARYFILE="/cygdrive$BINARYFILE"
fi

ORIGINALSIGNATURE=$(get_md5sum $BINARYFILE)
rm -f docker/noisy $BINARYFILE

printf "${ORANGE}* Building noisy ${NC}\n"
bash build.sh "$SRC" "$DST"

if [ -x $BINARYFILE ]
then
	SIGNATURE=$(get_md5sum $BINARYFILE)
	IMAGEVERSION=$(docker images | grep "$IMAGENAME" | awk '{ print $2 }')
	if [ -z "$IMAGEVERSION" ]
	then
		# the image does not exists so it should be built
		FORCEIMAGEBUILD=1
	else
		VERSION=$IMAGEVERSION
	fi

	if [ "$SIGNATURE" == "$ORIGINALSIGNATURE" -a "$FORCEIMAGEBUILD" == "0" ]
	then
		printf "${BLUE}* skiping image generation, since the app has not changed${NC}\n"
	else
		if [ "$IMAGEVERSION" ]
		then
			printf "${ORANGE}* Deleting image $IMAGENAME:$VERSION ${NC}\n"
			docker rmi $IMAGENAME:$VERSION
		fi
		TAGVERSION=$(git tag | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$" | tail -n 1)
		if [ "$TAGVERSION" ]
		then
			PATCHNUMBER=$(echo "$TAGVERSION" | grep -Eo "[0-9]+$")
			VERSION=${TAGVERSION%$PATCHNUMBER}$((PATCHNUMBER+1))
		fi
		printf "${ORANGE}* Building docker image $IMAGENAME:$VERSION ${NC}\n"
		cp $BINARYFILE docker/
		docker build -t $IMAGENAME:$VERSION docker/
	fi
	IMAGESNUMBER=$(docker images $IMAGENAME:$VERSION --format "{{.ID}}" | wc -l)
	if [ $IMAGESNUMBER -gt 0 ]
	then
		printf "${ORANGE}* Running container ${NC}\n"
		docker run --rm -i $IMAGENAME:$VERSION
	fi
	exit 0
fi

printf  "${RED}* Build failed!!${NC}\n"
exit 1
