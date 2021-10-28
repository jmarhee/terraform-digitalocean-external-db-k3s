locals {
  ssh_key_name = "rancher-key"
}

resource "random_id" "cloud" {
  byte_length = 8
}

resource "tls_private_key" "ssh_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "cluster_private_key_pem" {
  content         = chomp(tls_private_key.ssh_key_pair.private_key_pem)
  filename        = pathexpand(format("%s", local.ssh_key_name))
  file_permission = "0600"
}

resource "local_file" "cluster_public_key" {
  content         = chomp(tls_private_key.ssh_key_pair.public_key_openssh)
  filename        = pathexpand(format("%s.pub", local.ssh_key_name))
  file_permission = "0600"
}

resource "digitalocean_ssh_key" "terraform_rancher-k3s" {
  name       = format("terraform-k8s-%s", random_id.cloud.b64_url)
  public_key = tls_private_key.ssh_key_pair.public_key_openssh
}
