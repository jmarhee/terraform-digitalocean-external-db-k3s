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

function init_cluster {
  curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest K3S_URL=https://${K3S_CONTROLLER_IP}:6443 K3S_TOKEN="$(cat /root/node-token)" sh -s - agent
}

node_token && \
init_cluster