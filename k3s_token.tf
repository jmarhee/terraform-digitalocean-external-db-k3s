resource "random_string" "k3s_token" {
  length  = 16
  special = false
}