#!/bin/bash

BINARYFILE=docker/noisy
DOMAIN=ppamo.cl
APPNAME=noisy

get_md5sum(){
	unset MD5SUM
	if [ -f "$1" ]
	then
		md5sum "$1" | awk '{ print $1 }'
	fi
}

ORIGINALSIGNATURE=$(get_md5sum $BINARYFILE)
rm -f $BINARYFILE

echo "* Building noisy"
go get && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o $BINARYFILE .

if [ $? -eq 0 ]
then
	if [ -x $BINARYFILE ]
	then
		VERSION=$(docker images | grep "$DOMAIN/$APPNAME" | awk '{ print $2 }')
		if [ -z "$VERSION" ]
		then
			VERSION="1.0.0"
		else
			echo "* Deleting image $DOMAIN/$APPNAME:$VERSION"
			docker rmi $DOMAIN/$APPNAME:$VERSION
		fi
		SIGNATURE=$(get_md5sum $BINARYFILE)
		echo "=> comparing md5sum $ORIGINALSIGNATURE ? $SIGNATURE"
		echo "* Building docker image $DOMAIN/$APPNAME:$VERSION"
		docker build -t $DOMAIN/$APPNAME:$VERSION docker/
		exit 0
	fi
fi
echo "Filed!!"
exit 1
