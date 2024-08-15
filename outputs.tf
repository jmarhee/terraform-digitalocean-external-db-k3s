output "kubeconfig_base64" {
  description = "Base64 encoded kubeconfig string"
  value       = data.external.k3s_config.result.kubeconfig
}

output "kubeconfig_location" {
  description = "Your Kubeconfig"
  value       = "${path.module}/${pathexpand(format("%s-config", var.cluster_name))}"
}

output "control_plane_lb_address" {
  description = "K3s Control Plane Load Balancer Address"
  value       = digitalocean_loadbalancer.kubernetes_lb.ip
}

output "control_plane_nodes" {
  description = "K3s Control Plane Node IP Addresses"
  value       = "${digitalocean_droplet.control-plane-init.ipv4_address}, ${join(", ", digitalocean_droplet.control-plane-replica.*.ipv4_address)}"
}

output "worker_nodes" {
  description = "K3s Worker Nodes"
  value       = digitalocean_droplet.node.*.ipv4_address
}
