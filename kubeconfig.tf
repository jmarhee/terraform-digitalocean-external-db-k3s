data "external" "k3s_config" {
  depends_on = [digitalocean_droplet.controller-init, digitalocean_droplet.controller-peer]
  program    = ["/bin/bash", "${path.module}/scripts/retrieve_kubeconfig.sh", "${digitalocean_droplet.controller-init.ipv4_address}", "${pathexpand(format("%s", local.ssh_key_name))}"]
}

resource "local_file" "cluster_k3s_config" {
  content         = textdecodebase64(data.external.k3s_config.result.kubeconfig, "UTF-8")
  filename        = pathexpand(format("%s-config", var.cluster_name))
  file_permission = "0600"
}
