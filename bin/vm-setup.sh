#!/bin/bash
set -e
set -o pipefail

echo "Jai Guru"

printenv

cd "$HOME"

sed -i -E "s|(.*server: https://)127.0.0.1(:6443)|\1$(kubectl --context=$CLUSTER1 get nodes -owide --no-headers | awk '{print $6}')\2|g"  /var/lib/istio/.kube/config
sed -i -E "s|(.*server: https://)127.0.0.1(:6443)|\1$(kubectl --context=$CLUSTER1 get nodes -owide --no-headers | awk '{print $6}')\2|g"  /root/.kube/config

ISTIO_CTL_CMD="$ISTIO_HOME/bin/istioctl"

kubectl config get-contexts

cat <<EOF | envsubst | kubectl --context="$ISTIO_CLUSTER" apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: ${VM_NAMESPACE}
spec: {}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${SERVICE_ACCOUNT}
  namespace: ${VM_NAMESPACE}
EOF

cat <<EOF | envsubst | tee "$VM_WORK_DIR/workload-group.yaml"
apiVersion: networking.istio.io/v1alpha3
kind: WorkloadGroup
metadata:
  name: "${VM_APP}"
  namespace: "${VM_NAMESPACE}"
spec:
  metadata:
    labels:
      app: "${VM_APP}"
  template:
    serviceAccount: "${SERVICE_ACCOUNT}"
    network: "${VM_NETWORK}"
EOF

$ISTIO_CTL_CMD x workload entry configure \
      --file="$VM_WORK_DIR/workload-group.yaml" \
      --output="${VM_WORK_DIR}" \
      --clusterID="$CLUSTER" \
      --context="$ISTIO_CLUSTER"

sudo mkdir -p /etc/certs
sudo cp "${VM_WORK_DIR}/root-cert.pem" /etc/certs/root-cert.pem

sudo mkdir -p /var/run/secrets/tokens
sudo cp "${VM_WORK_DIR}/istio-token" /var/run/secrets/tokens/istio-token

sudo cp "${VM_WORK_DIR}/cluster.env" /var/lib/istio/envoy/cluster.env
sudo cp "${VM_WORK_DIR}/mesh.yaml" /etc/istio/config/mesh

sudo mkdir -p /etc/istio/proxy

sudo chown -R istio-proxy /var/lib/istio /etc/certs /etc/istio/proxy /etc/istio/config /var/run/secrets /etc/certs/root-cert.pem
