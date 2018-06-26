#! /bin/sh

ARTIFACT=$1
VERSION=$2
ENVIRONMENT=$3
HOOK_URL=$4

MESSAGE="($ARTIFACT) Deployed version $VERSION to the $ENVIRONMENT environment"

curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$MESSAGE\"}" ${HOOK_URL}
