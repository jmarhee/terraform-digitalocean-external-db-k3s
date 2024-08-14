resource "digitalocean_loadbalancer" "kubernetes_lb" {
  name   = "loadbalancer-1"
  region = var.cluster_region

  # https://docs.k3s.io/installation/requirements#inbound-rules-for-k3s-nodes

  forwarding_rule {
    entry_port     = 6443
    entry_protocol = "tcp"

    target_port     = 6443
    target_protocol = "tcp"
  }

  healthcheck {
    port     = 6443
    protocol = "tcp"
  }

  droplet_tag = "${var.cluster_name}-control-plane"
}
