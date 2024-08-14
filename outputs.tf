output "controller_addresses" {
  description = "Kubernetes Controller IP Addresses"
  value       = "${digitalocean_droplet.control-plane-init.ipv4_address}\n"
}

output "controller_peers" {
  description = "Control Plane Nodes"
  value       = digitalocean_droplet.control-plane-replica.*.ipv4_address
}

output "worker_nodes" {
  description = "Worker Nodes"
  value       = digitalocean_droplet.node.*.ipv4_address
}

output "kubeconfig" {
  description = "Your Kubeconfig"
  value       = "${path.module}/${pathexpand(format("%s-config", var.cluster_name))}"
}

output "kubeconfig_base64" {
  description = "Base64 encoded kubeconfig string"
  value       = data.external.k3s_config.result.kubeconfig
}

output "cluster_lb_address" {
  description = "K3s Cluster LB Address"
  value       = digitalocean_loadbalancer.kubernetes_lb.ip
}
