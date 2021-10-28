resource "random_id" "k3sdb" {
  byte_length = 8
}

resource "digitalocean_database_cluster" "rancherdb" {
  name       = var.database_cluster_name
  engine     = "mysql"
  version    = "8"
  size       = var.database_size
  region     = var.database_region
  node_count = var.database_node_count
}

resource "digitalocean_database_firewall" "rancherdb-fw-controller" {
  depends_on = [digitalocean_droplet.controller-init, digitalocean_droplet.controller-peer]
  cluster_id = digitalocean_database_cluster.rancherdb.id

  rule {
    type  = "tag"
    value = "${var.cluster_name}-control-plane"
  }
}
