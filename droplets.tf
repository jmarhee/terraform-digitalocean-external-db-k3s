data "template_file" "controller-init" {
  depends_on = [digitalocean_database_cluster.rancherdb]
  template   = file("${path.module}/templates/control-plane-init.tpl")
  vars = {
    # RANCHER_DATA_SOURCE = digitalocean_database_cluster.rancherdb.private_uri
    # RANCHER_DATA_SOURCE = "mysql://doadmin:${nonsensitive(digitalocean_database_cluster.rancherdb.password)}@tcp(${digitalocean_database_cluster.rancherdb.private_host}:3306)/default"
    RANCHER_DATA_SOURCE = "mysql://doadmin:${nonsensitive(digitalocean_database_cluster.rancherdb.password)}@tcp(${digitalocean_database_cluster.rancherdb.host}:${digitalocean_database_cluster.rancherdb.port})/defaultdb"
  }
}

resource "digitalocean_droplet" "controller-init" {
  depends_on = [digitalocean_database_cluster.rancherdb]
  image      = "ubuntu-20-04-x64"
  name       = "${var.cluster_name}-controller-00"
  region     = var.cluster_region
  size       = var.control_plane_size
  ssh_keys   = [digitalocean_ssh_key.terraform_rancher-k3s.fingerprint]
  tags       = ["${var.cluster_name}-control-plane"]
  user_data  = data.template_file.controller-init.rendered

}

data "template_file" "controller-peer" {
  depends_on = [digitalocean_database_cluster.rancherdb, digitalocean_droplet.controller-init]
  template   = file("${path.module}/templates/control-plane-peer.tpl")
  vars = {
    # RANCHER_DATA_SOURCE = "mysql://doadmin:${nonsensitive(digitalocean_database_cluster.rancherdb.password)}@tcp(${digitalocean_database_cluster.rancherdb.private_host}:3306)/default"
    RANCHER_DATA_SOURCE = "mysql://doadmin:${nonsensitive(digitalocean_database_cluster.rancherdb.password)}@tcp(${digitalocean_database_cluster.rancherdb.host}:${digitalocean_database_cluster.rancherdb.port})/defaultdb"
  }
}

resource "digitalocean_droplet" "controller-peer" {
  depends_on = [digitalocean_database_cluster.rancherdb, digitalocean_droplet.controller-init]
  image      = "ubuntu-20-04-x64"
  name       = format("${var.cluster_name}-controller-%02d", count.index + 1)
  region     = var.cluster_region
  size       = var.control_plane_size
  count      = var.controller_peer_count
  ssh_keys   = [digitalocean_ssh_key.terraform_rancher-k3s.fingerprint]
  tags       = ["${var.cluster_name}-control-plane"]
  user_data  = data.template_file.controller-peer.rendered

  provisioner "local-exec" {
    command = "sleep 360; /usr/bin/scp -3 -i ${pathexpand(format("%s", local.ssh_key_name))} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@${digitalocean_droplet.controller-init.ipv4_address}:/var/lib/rancher/k3s/server/node-token root@${self.ipv4_address}:node-token"
  }
}

data "template_file" "node" {
  depends_on = [digitalocean_database_cluster.rancherdb, digitalocean_droplet.controller-init]
  template   = file("${path.module}/templates/node.tpl")
  vars = {
    # K3S_CONTROLLER_IP = digitalocean_loadbalancer.rancher-k3s.ip
    K3S_CONTROLLER_IP = digitalocean_droplet.controller-init.ipv4_address
  }
}

resource "digitalocean_droplet" "node" {
  depends_on = [digitalocean_database_cluster.rancherdb, digitalocean_droplet.controller-init]
  image      = "ubuntu-20-04-x64"
  name       = format("${var.cluster_name}-worker-%02d", count.index)
  region     = var.cluster_region
  size       = var.node_size
  ssh_keys   = [digitalocean_ssh_key.terraform_rancher-k3s.fingerprint]
  tags       = ["${var.cluster_name}-node"]
  count      = var.worker_node_count
  user_data  = data.template_file.node.rendered

  provisioner "local-exec" {
    command = "sleep 360; /usr/bin/scp -3 -i ${pathexpand(format("%s", local.ssh_key_name))} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@${digitalocean_droplet.controller-init.ipv4_address}:/var/lib/rancher/k3s/server/node-token root@${self.ipv4_address}:node-token"
  }
}


