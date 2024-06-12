#!/bin/bash

# function check_cluster {
#   sleep 60 ; \
#   if [ -e /var/lib/rancher/k3s/server/node-token ]; then echo "Ready!"; else echo "node-token not present"; exit 1; fi
# }

# function init_cluster {
  curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest K3S_TOKEN="${GENERATED_K3S_TOKEN}" sh -s - server --datastore-endpoint="${RANCHER_DATA_SOURCE}" ; \
  # sleep 30
# }

# init_cluster && \
# check_cluster