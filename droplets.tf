data "template_file" "control-plane-init" {
  depends_on = [digitalocean_database_cluster.rancherdb]
  template   = file("${path.module}/templates/control-plane-init.tpl")
  vars = {
    RANCHER_DATA_SOURCE = "postgres://doadmin:${nonsensitive(digitalocean_database_cluster.rancherdb.password)}@${digitalocean_database_cluster.rancherdb.host}:${digitalocean_database_cluster.rancherdb.port}/defaultdb?sslmode=require"
    GENERATED_K3S_TOKEN = random_string.k3s_token.result
    LOAD_BALANCER_VIP   = digitalocean_loadbalancer.kubernetes_lb.ip
  }
}

resource "digitalocean_droplet" "control-plane-init" {
  depends_on = [digitalocean_database_cluster.rancherdb, digitalocean_loadbalancer.kubernetes_lb]
  image      = "almalinux-9-x64"
  name       = "${var.cluster_name}-control-plane-00"
  region     = var.cluster_region
  size       = var.control_plane_size
  ssh_keys   = [digitalocean_ssh_key.terraform_rancher-k3s.fingerprint]
  tags       = ["${var.cluster_name}-control-plane"]
  user_data  = data.template_file.control-plane-init.rendered

}

data "template_file" "control-plane-replica" {
  depends_on = [digitalocean_database_cluster.rancherdb, digitalocean_droplet.control-plane-init]
  template   = file("${path.module}/templates/control-plane-replica.tpl")
  vars = {
    RANCHER_DATA_SOURCE = "postgres://doadmin:${nonsensitive(digitalocean_database_cluster.rancherdb.password)}@${digitalocean_database_cluster.rancherdb.host}:${digitalocean_database_cluster.rancherdb.port}/defaultdb?sslmode=require"
    GENERATED_K3S_TOKEN = random_string.k3s_token.result
  }
}

resource "digitalocean_droplet" "control-plane-replica" {
  depends_on = [digitalocean_database_cluster.rancherdb, digitalocean_droplet.control-plane-init, digitalocean_loadbalancer.kubernetes_lb]
  image      = "almalinux-9-x64"
  name       = format("${var.cluster_name}-control-plane-%02d", count.index + 1)
  region     = var.cluster_region
  size       = var.control_plane_size
  count      = var.controller_peer_count
  ssh_keys   = [digitalocean_ssh_key.terraform_rancher-k3s.fingerprint]
  tags       = ["${var.cluster_name}-control-plane"]
  user_data  = data.template_file.control-plane-replica.rendered
}

data "template_file" "node" {
  depends_on = [digitalocean_database_cluster.rancherdb, digitalocean_droplet.control-plane-init, digitalocean_loadbalancer.kubernetes_lb]
  template   = file("${path.module}/templates/node.tpl")
  vars = {
    K3S_CONTROLLER_IP   = digitalocean_loadbalancer.kubernetes_lb.ip
    GENERATED_K3S_TOKEN = random_string.k3s_token.result
  }
}

resource "digitalocean_droplet" "node" {
  depends_on = [digitalocean_database_cluster.rancherdb, digitalocean_droplet.control-plane-init]
  image      = "almalinux-9-x64"
  name       = format("${var.cluster_name}-worker-%02d", count.index)
  region     = var.cluster_region
  size       = var.node_size
  ssh_keys   = [digitalocean_ssh_key.terraform_rancher-k3s.fingerprint]
  tags       = ["${var.cluster_name}-node"]
  count      = var.worker_node_count
  user_data  = data.template_file.node.rendered
}
