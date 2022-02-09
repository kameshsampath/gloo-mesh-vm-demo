# Istio VM Demo

A simple microservices demo to show how to onboard VM workloads with Istio and make them work with Kubernetes services. The demo also shows how to use [Gloo Mesh](https://solo.io/products/gloo-mesh) to add features like Traffic Policy, Access Policy etc., that spans across Kubernetes and VM workloads.

Checkout the [HTML Documentation](https://kameshsampath.github.io/gloo-mesh-vm-demo/)
for a detailed DIY guide.

## Tools

- Python3
- [direnv](https://direnv.net)
- [multipass](https://multipass.run/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [calico](https://projectcalico.docs.tigera.io/)
- [jq](https://stedolan.github.io/jq/)

## Download Sources

```shell
git clone https://github.com/kameshsampath/gloo-mesh-vm-demo
cd gloo-mesh-vm-demo
```

## Demo Architecture

![Demo Architecture](./docs/images/architecture.png "Demo Architecture")

## Ensure Environment

```shell
direnv allow .
```

The [Makefile](./Makefile) in the `$PROJECT_HOME` helps to perform the various setup tasks,

```shell
make help
```

```text
help:                        print this help message
setup-ansible:               setup ansible environment
clean-up:                    cleans the setup and environment
create-vms:                  create the multipass vms
create-kubernetes-clusters:   Installs k3s on the multipass vms
deploy-base:                  Prepare the vm with required packages and tools
deploy-istio:                 Deploy Istio on to workload cluster
deploy-gloo:                  Deploy Gloo Mesh on to management and workload clusters
deploy-workload:              Deploy workload recommendation service on vm
```

## Setup Ansible Environment

The demo will be using [Ansible](https://docs.ansible.com/) to setup the environment, run the following command to install Ansible modules and extra collections and roles the will be used by various tasks.

```shell
make setup-ansible
```

## Create Virtual Machines

```shell
make create-vms
```

## Kubernetes Cluster

### Settings

The k3s cluster will be a single node cluster run via multipass VM. We will configure that to with the following flags,

- `--cluster-cidr=172.16.0.0/24` allows us to create 65 – 110 Pods on this node
- `--service-cidr=172.18.0.0/20` allows us to create 4096 services
- `--disable=traefik` disable `traefik` deployment

For more information on how to calculate the number of pods and service per CIDR rang, check the [GKE doc](https://cloud.google.com/kubernetes-engine/docs/concepts/alias-ips).

### Create Kubernetes Cluster

The following command will create kubernetes(k3s) cluster and configure it with [Calico](https://projectcalico.docs.tigera.io) plugin.

```shell
make create-kubernetes-clusters
```

## Deploy Gloo Mesh

```shell
make deploy-gloo
```

## Deploy Istio

```shell
make deploy-istio
```

## Deploy Demo Applications

```shell
helm repo add istio-demo-apps https://github.com/kameshsampath/istio-demo-apps
helm repo update
```

```shell
kubectl --context="$CLUSTER1" label ns default istio.io/rev=1-11-5
```

Deploy Customer,

```shell
helm install --kube-context="$CLUSTER1" \
  customer istio-demo-apps/customer \
  --set enableIstioGateway="true"
```

Deploy Preference,

```shell
helm install --kube-context="$CLUSTER1" \
  preference istio-demo-apps/preference 
```

Call the service to test,

```bash
export INGRESS_GATEWAY_IP=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}')
export SVC_URL="${INGRESS_GATEWAY_IP}/customer"
```

```shell
curl $SVC_URL
```

The command should shown an output like,

```text
customer => preference => Service host 'http://recommendation:8080' not known.%
```

## Deploy Istio Sidecar Virtual Machine

Install some essential packages on the vms,

```shell
make deploy-base
```

Deploy the workload the `recommendation` service,

```shell
make deploy-workload
```

## Calling Services

### From Kubernetes to VM

```shell
curl $SVC_URL
```

The command should shown an output like,

```text
customer => preference => recommendation v1 from 'vm1': 2
```

### From VM to Kubernetes

Shell into the `vm1`,

```shell
multipass exec vm1 bash
```

```shell
curl --connect-timeout 3 customer.default.svc.cluster.local:8080
```

You might not get a response to the command and when checking the sidecar logs on the `vm1` you should see something like:

```text
[2022-02-09T13:34:21.473Z] "GET / HTTP/1.1" 503 UF,URX upstream_reset_before_response_started{connection_failure} - "-" 0 91 24255 - "-" "curl/7.68.0" "5ab981ed-c95f-4730-8732-2fe6fd7f6208" "customer.default.svc.cluster.local:8080" "172.16.0.15:8080" outbound|8080||customer.default.svc.cluster.local - 172.18.2.58:8080 192.168.205.6:34832 - default
```

Let's fix it by adding routes to our pods and services,

```shell
export CLUSTER1_IP=$(kubectl get nodes -owide --no-headers  | awk 'NR==1{print $6}')
sudo ip route add 172.16.0.0/28 via $CLUSTER1_IP
sudo ip route add 172.18.0.0/20 via $CLUSTER1_IP
```

Now running the following command from the `vm1`,

```shell
curl --connect-timeout 3 customer.default.svc.cluster.local:8080
```

The command should shown an output like,

```text
customer => preference => recommendation v1 from 'vm1': 2
```

## Cleanup

```shell
make clean-up
```
