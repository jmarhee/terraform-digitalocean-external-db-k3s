# High-Availability K3s on DigitalOcean

[![Build Status](https://cloud.drone.io/api/badges/jmarhee/terraform-digitalocean-kubernetes/status.svg)](https://cloud.drone.io/jmarhee/terraform-digitalocean-kubernetes)

Terraform module to deploy a highly-available K3s cluster using DigitalOcean DBaaS-backed Postgres cluster.

## Architecture

This module deploys a Postgres cluster that the control plane pool will connect to on startup, a load balancer that the workers will register through to the control plane pool, and a set of worker nodes that will be managed by the control plane pool.

This setup is fully highly available. The control plane pool is set up to be `n+1` nodes, where `n` is the number of replicas of the initial control plane node you specify in your .tfvars file. To scale this pool, manage the `control_plane_replica_count` variable.

The worker pool size is managed by the `worker_node_count` variable, and can be scaled up or down as needed.

The cluster kubeconfig will connect to the control plane nodes through the load balancer address through the `cluster_lb_address` output value. This will be located in the module root at the end of `terraform apply`.

The status of cluster spin-up after `apply` completes can be checked by running:
```bash
kubectl --kubeconfig=rancher-k3s-config get nodes -w
```
where for example `var.cluster_name` was set to `rancher-k3s` and your kubeconfig file will be appended by `-config`.

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
