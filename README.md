# High-Availability K3s

[![Build Status](https://cloud.drone.io/api/badges/jmarhee/terraform-digitalocean-kubernetes/status.svg)](https://cloud.drone.io/jmarhee/terraform-digitalocean-kubernetes)

Terraform module to deploy a highly-available K3s cluster using DigitalOcean DBaaS-backed MySQL cluster. 

## Usage

Set `TF_VAR_database_node_count`, `TF_VAR_controller_peer_count`, `TF_VAR_worker_node_count`, and `TF_VAR_digitalocean_token` and apply:

```bash
terraform plan
terraform apply -auto-approve
```

Options for region, node sizing, and cluster name are available as variables as well.

## Kubeconfig

At the end of the run, your Kubeconfig filepath will appear in the output, and will be stored in the project root as `${var.cluster_name}-config`. This file is managed by Terraform, and is stored in state as a `base64`-encoded string, and can be viewed using `textdecodebase64(data.external.k3s_config.result.kubeconfig, "UTF-8")` in your Terrform console.

The output value of `kubeconfig_base64` can be used to export this configuration from this module for use with the Kubernetes or Helm providers, for example, using the above `textdecodebase64()` function.