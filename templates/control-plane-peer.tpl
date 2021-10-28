#!/bin/bash

function node_token {
  while true; do \
    if [ ! -f /root/node-token ]; then \
      echo "Node-token not ready...rechecking in 20 seconds..." ; \
      sleep 20
    else
      echo "Node-token ready...proceeding with K3s configuration..." ; \
      break
    fi
  done
}

function check_cluster {
  sleep 60 ; \
  if [ -e /var/lib/rancher/k3s/server/node-token ]; then echo "Ready!"; else echo "node-token not present"; exit 1; fi
}

function init_cluster {
  curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest sh -s - server --datastore-endpoint="${RANCHER_DATA_SOURCE}" --token "$(cat /root/node-token)" && \
  sleep 30
}

node_token && \
init_cluster 