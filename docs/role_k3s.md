---
title: k3s
summary: Ansible Role to setup k3s on the multipass VMs
authors:
  - Kamesh Sampath<kamesh.sampath@hotmail.com>
date: 2022-01-10
---

This role helps in installing and configuring [k3s](https://k3s.io) the Kubernetes cluster. The role by default installs k3s with [Calico](https://projectcalico.docs.tigera.io/about/about-calico) network plugin and disables `traefik`. This role is trimmed down version of <https://github.com/k3s-io/k3s-ansible> to just support single node k3s cluster.

## Requirements

- Virtual Machines are provisioned using the `multipass` role  
- `$DEMO_HOME/inventory/hosts` is setup

## Variables

| Name  | Description | Default
| ----------- | ----------- | ---
| k3s_version | The k3s Kubernetes version | `v1.21.8+k3s1`
| k3s_server_location| The k3s server location | `/var/lib/rancher/k3s`
| k3s_cluster_cidr | The Kubernetes Cluster IP CIDR to use | k3s_cluster_cidr
| k3s_service_cidr | The Kubernetes Service IP CIDR to use  | 172.18.0.0/20
| k3s_deploy_calico_network_plugin | Use helm secrets plugin with argocd applications | yes
| extra_server_args | extra_server_args | `--write-kubeconfig-mode 644 "--flannel-backend=none --cluster-cidr={{ k3s_cluster_cidr }} --service-cidr={{ k3s_service_cidr}} --disable-network-policy --disable=traefik`
