#!/bin/bash

TAG=$TAG
TAG_COMMIT=$(git rev-parse --short ${TAG})

AUTH_TOKEN=$GITHUB_TOKEN

curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/jmarhee/putio-cli-v2/releases" \
  -d "{
    \"tag_name\": \"$TAG\",
    \"name\": \"Release $TAG\",
    \"body\": \"Release notes for $TAG_COMMIT\",
    \"draft\": false,
    \"prerelease\": false
  }"
