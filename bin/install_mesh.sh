#!/usr/bin/env bash

set -eu
set -o pipefail 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/currentEnv.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/helpers.sh"

if [ -z "${GLOO_MESH_GATEWAY_LICENSE_KEY}" ];
then
  printf 'Please set GLOO_MESH_GATEWAY_LICENSE_KEY with Gloo Mesh Gateway Enterprise License\n'
  exit 1
fi

kubectl --context "${MGMT}"  create namespace gloo-mesh || true

helm repo add gloo-mesh-enterprise https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-enterprise 
helm repo update

GLOO_MESH_EE_VERSION=$(helm search repo gloo-mesh-enterprise/gloo-mesh-enterprise -ojson | jq -r '.[0].version' )

helm install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise \
--namespace gloo-mesh --kube-context "${MGMT}" \
--version="${GLOO_MESH_EE_VERSION}" \
--set rbac-webhook.enabled=true \
--set licenseKey="${GLOO_MESH_GATEWAY_LICENSE_KEY}" \
--set "rbac-webhook.adminSubjects[0].kind=Group" \
--set "rbac-webhook.adminSubjects[0].name=system:masters" \
--wait

exit 0;