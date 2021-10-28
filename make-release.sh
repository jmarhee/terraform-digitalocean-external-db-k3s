#!/bin/bash

TAG=$TAG
TAG_COMMIT=$(git rev-parse --short ${TAG})

AUTH_TOKEN=$GITHUB_TOKEN
curl \
  -X POST "https://api.github.com/repos/jmarhee/terraform-digitalocean-ha-k3s/releases" -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d "{  \"body\": \"Cutting ${TAG} at ${TAG_COMMIT}\",  \"draft\": false,  \"name\": \"${TAG}\",  \"prerelease\": false,  \"tag_name\": \"${TAG}\" }"

