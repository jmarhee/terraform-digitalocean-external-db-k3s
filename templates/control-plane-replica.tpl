#!/bin/bash

curl -sfL https://get.k3s.io | \
INSTALL_K3S_CHANNEL=latest K3S_TOKEN="${GENERATED_K3S_TOKEN}" \
sh -s - server --datastore-endpoint="${RANCHER_DATA_SOURCE}" \
--tls-san "${LOAD_BALANCER_VIP}" \
--tls-san "${CONTROL_PLANE_INIT_IP}" \
--tls-san "$(curl http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)"
