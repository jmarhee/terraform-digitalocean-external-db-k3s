#!/bin/bash

curl -sfL https://get.k3s.io | \
INSTALL_K3S_CHANNEL=latest K3S_TOKEN="${GENERATED_K3S_TOKEN}" \
sh -s - server --datastore-endpoint="${RANCHER_DATA_SOURCE}"
