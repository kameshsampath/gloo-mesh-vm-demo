#!/bin/bash

set -eu
set -o pipefail 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/currentEnv.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/helpers.sh"

export KUBECONFIG=$TUTORIAL_HOME/work/.kube/config

if [ -z "$1" ];
then 
  echo "Please pass the cluster context"
  exit 1
fi

# Operator install
printf "\n Installing Istio on cluster '%s' \n" "${1}"

kubectl  --context="${1}" create ns istio-operator || true
istioctl --context="${1}" operator init 

kubectl --context="${1}" rollout status deploy/istio-operator -n istio-operator --timeout=120s

envsubst < "$TUTORIAL_HOME/cluster/istio/istio-cr.yaml" | kubectl --context "${1}" apply -f -

printf "Waiting for the Istio Deployments to be created...\n"

sleep 30

kubectl --context="${1}" rollout status deploy/istiod -n istio-system --timeout=120s
kubectl --context="${1}" rollout status deploy/istio-ingressgateway -n istio-system --timeout=120s

printf "Enable mTLS n \n"

kubectl --context="${1}" apply -f "$TUTORIAL_HOME/mesh-files/peer-auth.yaml" 

exit 0;