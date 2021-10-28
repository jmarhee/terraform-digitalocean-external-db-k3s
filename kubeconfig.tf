resource "null_resource" "cluster" {
  depends_on = [digitalocean_database_cluster.rancherdb, digitalocean_droplet.controller-init, digitalocean_droplet.controller-peer]

  provisioner "local-exec" {
    command = "sleep 1; /usr/bin/ssh -i ${pathexpand(format("%s", local.ssh_key_name))} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@${digitalocean_droplet.controller-init.ipv4_address} cat /etc/rancher/k3s/k3s.yaml | sed -e 's|127.0.0.1:6443|${digitalocean_droplet.controller-init.ipv4_address}:6443|g' -e 's|/var/lib/rancher/k3s/server/tls/||g' | tee -a ${path.module}/cluster-config-k3s"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig=cluster-config-k3s get nodes"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm ${path.module}/cluster-config-k3s"
  }

}

