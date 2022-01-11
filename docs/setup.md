---
title: Setup
summary: Set up the environment for the demo

authors:
  - Kamesh Sampath<kamesh.sampath@hotmail.com>
date: 2022-01-10
---

At the end of this chapter you would have setup the environment and tools that are required for the demo.

---8<--- "includes/tools.md"

## Download Sources

```shell
git clone https://github.com/kameshsampath/gloo-mesh-vm-demo
cd gloo-mesh-vm-demo
```

For the rest of the instructions, the cloned sources folder will be referred to as `$DEMO_HOME`.

## Ensure Environment

Assuming you have downloaded [direnv](https://direnv.net){target=_blank} and hooked it to your [shell](https://direnv.net/docs/hook.html){target=_blank}.

```shell
direnv allow .
```

## Setup Ansible Environment

The demo will be using [Ansible](https://docs.ansible.com/){target=_blank} to setup the environment, run the following command to install Ansible modules and extra collections and roles the will be used for various tasks.

```shell
make setup-ansible
```

!!! important
    The demo uses [direnv](https://direnv.net){target=_blank} to create a local Python Virtual Environment.

## Ansible Variables

| Variable | Description                        | Default Value | Ansible Role
| :------- | :----------------------------------| :------------ | :------------


## Create Virtual Machines

For the demo we will be using [multipass](https://multipass.run){target=_blank} to create and run virtual machines. Run the following command to create the virtual machines,

```shell
make create-vms
```

The previous command would have created three VMs namely,

- **mgmt** - which will act as Gloo Management Kubernetes cluster.
- **cluster1** - The Kubernetes cluster where Istio and its workloads will be deployed. The Virtual Machine workloads will use the  Istio Control Plane(CP) opn this cluster for its services.
- **vm1** - the Virtual Machine which will hold a small workload that will be connected to **cluster1**.

You can always get the information about the multipass VM using the command,

```shell
multipass info <vm name>
# e.g. 
multipass info cluster1
```

That should give an information like,

```text
Name:           cluster1
State:          Running
IPv4:           192.168.64.90
                172.16.0.0
Release:        Ubuntu 20.04.3 LTS
Image hash:     8fbc4e8c6e33 (Ubuntu 20.04 LTS)
Load:           2.37 1.88 1.76
Disk usage:     5.3G out of 28.9G
Memory usage:   1.8G out of 7.8G
Mounts:         --
```

## Setup Kubernetes Clusters

As part of this demo we will be setting up [k3s](https://k3s.io) Kubernetes clusters. The k3s clusters will be a single node cluster run via multipass VM. We will configure that to with the following flags,

- `--cluster-cidr=172.16.0.0/24` allows us to create **65 – 110** Pods on this node
- `--service-cidr=172.18.0.0/20` allows us to create **4096** services
- `--disable=traefik` disable `traefik` deployment

Check the GKE doc[^1] for a reference on how to calculate the number of pods and service with given CIDR range.

Run the following command to deploy the clusters to our `mgmt` and `cluster1` VMs.

```shell
make create-kubernetes-clusters
```

The previous step we should have two Kubernetes clusters `mgmt` and `cluster1` and as convenience it merges the two cluster `kubeconfig` into one as `$DEMO_HOME/work/.kube/config` which is set as the current shell `$KUBECONFIG` value. So doing `kubectl config get-contexts` now should return you two contexts.

```shell
CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
          cluster1   cluster1   cluster1
*         mgmt       mgmt       mgmt
```

!!! note
    The k3s deployment as part of this demo will be using [Calico](https://projectcalico.docs.tigera.io){target=_blank} which enables us to define routes to the Kubernetes services/pods via its [host](https://projectcalico.docs.tigera.io/networking/openstack/host-routes){target=_blank}.

## Setup Gloo

Let us setup on the `mgmt` cluster. The setup uses the Gloo Enterprise License, if you don't have one please request 30 day trial one via [solo.io](https://solo.io){target=_blank}. Set the License key via as `$GLOO_MESH_GATEWAY_LICENSE_KEY` environment variable.

Run the following command to deploy Gloo Mesh,

```shell
make deploy-gloo
```

Ensure Gloo mesh is setup correctly,

```shell
meshctl check server
```

```text
Gloo Mesh Management Cluster Installation
--------------------------------------------

🟢 Gloo Mesh Pods Status
+----------+------------+-------------------------------+-----------------+
| CLUSTER  | REGISTERED | DASHBOARDS AND AGENTS PULLING | AGENTS PUSHING  |
+----------+------------+-------------------------------+-----------------+
| cluster1 | true       |                             2 |               1 |
+----------+------------+-------------------------------+-----------------+

🟢 Gloo Mesh Agents Connectivity

Management Configuration
---------------------------

🟢 Gloo Mesh CRD Versions

🟢 Gloo Mesh Networking Configuration Resources
```

## Setup Istio

Lets now complete the environment setup part by deploying [Istio](https://istio.io) on to `cluster1`. We use Istio `1.11.5` for this tutorial,

```shell
make deploy-istio
```

Lets check if Istio setup is done correctly,

```shell
istioctl verify-install --context=$CLUSTER1
```

The command should show the following output ( trimmed for brevity),

```text
...
Checked 13 custom resource definitions
Checked 1 Istio Deployments
✔ Istio is installed and verified successfully
```

[^1]: https://cloud.google.com/kubernetes-engine/docs/concepts/alias-ips

---8<--- "includes/abbrevations.md"
