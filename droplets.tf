data "template_file" "controller-init" {
  depends_on = [digitalocean_database_cluster.rancherdb]
  template   = file("${path.module}/templates/control-plane-init.tpl")
  vars = {
    RANCHER_DATA_SOURCE = "postgres://doadmin:${nonsensitive(digitalocean_database_cluster.rancherdb.password)}@${digitalocean_database_cluster.rancherdb.host}:${digitalocean_database_cluster.rancherdb.port}/defaultdb?sslmode=require"
    GENERATED_K3S_TOKEN = random_string.k3s_token.result
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
    RANCHER_DATA_SOURCE = "postgres://doadmin:${nonsensitive(digitalocean_database_cluster.rancherdb.password)}@${digitalocean_database_cluster.rancherdb.host}:${digitalocean_database_cluster.rancherdb.port}/defaultdb?sslmode=require"
    GENERATED_K3S_TOKEN = random_string.k3s_token.result
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
}

data "template_file" "node" {
  depends_on = [digitalocean_database_cluster.rancherdb, digitalocean_droplet.controller-init]
  template   = file("${path.module}/templates/node.tpl")
  vars = {
    # K3S_CONTROLLER_IP = digitalocean_loadbalancer.rancher-k3s.ip
    K3S_CONTROLLER_IP   = digitalocean_droplet.controller-init.ipv4_address
    GENERATED_K3S_TOKEN = random_string.k3s_token.result
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
}


