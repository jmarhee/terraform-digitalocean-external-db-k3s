variable "digitalocean_token" {
  description = "Your DigitalOcean API Token"
}

variable "cluster_name" {
  description = "Cluster name"
  default     = "rancher-k3s"
}

variable "cluster_domain" {
  description = "Root Domain for Cluster"
}

variable "cluster_subdomain" {
  description = "DNS subdomain for cluster"
  default     = "k3s"
}

variable "cluster_region" {
  description = "Region for Cluster"
  default     = "nyc3"
}

variable "database_region" {
  description = "Region for MySQL Cluster"
  default     = "nyc3"
}

variable "control_plane_size" {
  description = "Control Plane Node Size"
  default     = "s-1vcpu-1gb"
}

variable "node_size" {
  description = "Worker Node Size"
  default     = "s-1vcpu-1gb"
}

variable "database_size" {
  description = "DB Node Size"
  default     = "db-s-1vcpu-1gb"
}

variable "database_node_count" {
  description = "Number of Database nodes in MySQL cluster"
  default     = 3
}

variable "database_admin_user" {
  description = "MySQL user name"
  default     = "rancher_admin"
}

variable "controller_peer_count" {
  description = "Number of additional Control Plane nodes"
  default     = 2
}

variable "worker_node_count" {
  description = "Number of worker nodes"
  default     = 3
}
