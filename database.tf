resource "random_string" "rancherdb" {
  length  = 6
  special = false
  numeric = false
  upper   = false
  lower   = true
}

resource "digitalocean_database_cluster" "rancherdb" {
  name       = random_string.rancherdb.result
  engine     = "pg"
  version    = "15"
  size       = var.database_size
  region     = var.database_region
  node_count = var.database_node_count
}

resource "digitalocean_database_firewall" "rancherdb-fw-controller" {
  depends_on = [digitalocean_droplet.control-plane-init, digitalocean_droplet.control-plane-replica]
  cluster_id = digitalocean_database_cluster.rancherdb.id

  rule {
    type  = "tag"
    value = "${var.cluster_name}-control-plane"
  }
}
