---
title: Workload VM
summary: Ansible Role to configure Workload VM
authors:
  - Kamesh Sampath<kamesh.sampath@hotmail.com>
date: 2022-01-10
---

This role helps in installing and configuring the Istio sidecar VM a.k.a Istio Workload VM.

## Requirements

- Access to k3s Kubernetes cluster

## Variables

| Name  | Description | Default
| ----------- | ----------- | ---
| workload_istio_ns | The Istio Control Plane namespace | istio-system
| workload_istio_gateway_ns| The Istio Gateways namespace | istio-gateways
| workload_istio_svc_name| The Istio Ingress Gateway name | ingressgateway
| force_app_install | Clean install VM workload application | no
| use_nodeport | Use nodeport to connect to Istiod | no
| istio_enabled | Install and configure Istio Sidecar in the VM | yes
| istio_vm_app | The name of the Istio VM app | istio_vm_app
| istio_vm_namespace | The Kubernetes namespace to create Istio VM Workload resources | vm-demos-app
| istio_vm_workdir | The directory to create Istio workload files | `/home/{{ ansible_user }}/istio-vm/files`
| istio_vm_service_account | The Kubernetes service account to use with Istio VM Workload resources | vm-service-account
| istio_cluster_network | The Istio Control Plane cluster network | network1
| istio_vm_network | The Istio VM network | vm-network
| istio_cluster | The Istio cluster context name | cluster1

---8<--- "includes/abbreviations.md"
