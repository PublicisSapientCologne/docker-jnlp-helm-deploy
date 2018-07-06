#! /bin/bash

VERSION=$1

if [[ $VERSION =~ ^[0-9]+\.[0-9+]\.[0-9]+$ ]] ; then
	echo Release version \"$VERSION\" detected.
	exit 0
else
	echo NON-Release version \"$VERSION\" detected.
	exit 1
fi