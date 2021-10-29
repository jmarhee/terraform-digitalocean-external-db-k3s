#!/bin/bash

CONTROLLER_IP=$1
KEY_PATH=$2

/bin/sleep 180 ; \
if [[ "$OSTYPE" == "darwin"* ]]; then
	CONFIG=$(/usr/bin/ssh -i \
	$KEY_PATH \
	-o StrictHostKeyChecking=no \
	-o UserKnownHostsFile=/dev/null -q \
	root@$CONTROLLER_IP cat /etc/rancher/k3s/k3s.yaml \
	| sed -e "s|127.0.0.1:6443|$CONTROLLER_IP:6443|g" \
	-e 's|/var/lib/rancher/k3s/server/tls/||g' | base64 -b 0)
else
	CONFIG=$(/usr/bin/ssh -i \
	$KEY_PATH \
	-o StrictHostKeyChecking=no \
	-o UserKnownHostsFile=/dev/null -q \
	root@$CONTROLLER_IP cat /etc/rancher/k3s/k3s.yaml \
	| sed -e "s|127.0.0.1:6443|$CONTROLLER_IP:6443|g" \
	-e 's|/var/lib/rancher/k3s/server/tls/||g' | base64 -w 0)
fi

echo -e "{\"kubeconfig\": \"$CONFIG\"}"

