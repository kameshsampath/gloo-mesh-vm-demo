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
work_dir| The work directory on the local machine | `{{ playbook_dir }}/work`
kubeconfig_dir| The directory to save all the kubeconfig files | `{{ work_dir }}/.kube`
kubernetes_cli_version | the kubectl version | v1.21.8
k3s_cluster_cidr | The Cluster CIDR(`cluster-cidr`) for Kubernetes Clusters | 172.16.0.0/24 | [k3s](./role_k3s.md)
k3s_service_cidr | The Service CIDR(service-cidr) for Kubernetes Clusters | 172.18.0.0/20 | [k3s](./role_k3s.md)
istio_enabled| Whether to configure the vms with Istio Sidecar | yes | [Workload](./role_workload_vm.md)
istio_vm_app| VM application name | recommendation | [Workload](./role_workload_vm.md)
istio_vm_namespace| The namespace in Kubernetes cluster i.e. `cluster1` | default | [Workload](./role_workload_vm.md)
istio_vm_workdir| The work dir in vm where the Istio Sidecar files will be created | `/home/{{ ansible_user }}/istio-vm/files` | [Workload](./role_workload_vm.md)
istio_vm_service_account| The Kubernetes Service Account to use when creating VM resources in Kubernetes | vm-service-account | [Workload](./role_workload_vm.md)
istio_cluster_network| The Istio Cluster Network the network | network1 | [Workload](./role_workload_vm.md)
istio_vm_network| The Istio network for VM communication | [Workload](./role_workload_vm.md)
istio_cluster| The Istio cluster name. The name in this demo maps to Kubernetes cluster context where to install Istio i.e `cluster1` and the same is used as SPIFEE trustDomain | cluster1 | [Workload](./role_workload_vm.md)
istio_cluster_service_ip_cidr| The Cluster Service IP CIDR to use with `istio_cluster` | `{{ k3s_service_cidr }}` | [Workload](./role_workload_vm.md)
istio_cluster_pod_ip_cidr| The Cluster IP CIDR to use with `istio_cluster` | `{{ k3s_cluster_cidr }}` | [Workload](./role_workload_vm.md)
workload_istio_ns| The namespace where Istio Control Plane is deployed in `istio_cluster` | `{{ k3s_cluster_cidr }}` | [Workload](./role_workload_vm.md)
workload_istio_gateway_ns| The namespace where Istio Ingress gateway is deployed in `istio_cluster` | `{{ k3s_cluster_cidr }}` | [Workload](./role_workload_vm.md)
clean_istio_vm_files| Clean the generated Istio sidecar VM files including the directories where it was copied in the VM| yes | [Workload](./role_workload_vm.md)
force_app_install| Clean install the VM application | no | [Workload](./role_workload_vm.md)

Apart from the variables defined, there are three other variables that controls the setup,

- `multipass_vms` - defines a dictionary of VMs that needs to be created,

```yaml
multipass_vms:
 # the name of the VM
 - name: mgmt
   # cpus to allocate
   cpus: 4
   # memory to allocate
   mem: 8g
   # disk size
   disk: 30g
   # roles of this vm
   role:
    - kubernetes
    - gloo
    - management
 - name: cluster1
   cpus: 4
   mem:  8g
   disk: 30g
   role:
    - kubernetes
    - gloo
    - workload
 - name: vm1
   cpus: 2
   mem: 2g
   disk: 30g
   role:
     - vm
```

- `gloo_clusters` - the Kubernetes clusters that wil be used for gloo deployment

```yaml
gloo_clusters:
  # name of the cluster
  mgmt:
    # cloud where its deployed
    cloud: k3s
    # the Kubernetes Context name, recommended it to be the name of VM where k3s runs
    k8s_context: mgmt
    # logical cluster name to be used while registering it with meshctl
    cluster_name: mgmt
  cluster1:
    cloud: k3s
    k8s_context: cluster1
    cluster_name: cluster1
```

- `istio_clusters` - the Kubernetes clusters where Istio will be deployed

```yaml
istio_clusters:
   # name of the cluster
   cluster1:
     # Kubernetes Context to use for this cluster
     k8s_context: "{{ gloo_clusters.cluster1.k8s_context }}"
     # The version of Istio that needs to be deployed
     version: "{{ lookup('env','ISTIO_VERSION') }}"
     install: yes
```

!!! tip
    The demo uses [asdf-vm](https://asdf-vm) to handle multiple versions of a software e.g. Python, Istio. Check out <https://github.com/kameshsampath/asdf-istio>

The setup uses direnv and the playbooks generates the .envrc using template form `$DEMO_HOME/templates/.envrc`. If needed adjust the .envrc template and rerun the create-vms and create-kubernetes-clusters task to refresh or update it.

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

The task finally generates Ansible Hosts inventory based on the template from `$DEMO_HOME/templates/hosts.j2`, which will be used as inventory in other playbook runs.

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

Let us setup on the `mgmt` cluster. The setup uses the Gloo Enterprise License, if you don't have one please request 30 day trial one via [solo.io](https://solo.io){target=_blank}. Set the License key via as `$GLOO_MESH_GATEWAY_LICENSE_KEY` environment variable and then run the following command to deploy Gloo Mesh,

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
