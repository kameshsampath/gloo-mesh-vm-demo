#!/bin/bash

set -eu 

source "$(basedir)/helpers.sh"

source "$(basedir)/currentEnv.sh"

export VM_APP="blue-green-canary"
export VM_NAMESPACE="vm-blue-green-canary"
export WORK_DIR="$TUTORIAL_HOME/cloud/private/vm"
export SERVICE_ACCOUNT="blue-green-canary"
export CLUSTER_NETWORK="bgc-network1"
export VM_NETWORK="bgc-vm-network"
export CLUSTER="cluster1"


printf "\n VM Environment \n"
printf "\n ======================================================== \n"
printf "\n VM Application Name : %s \n" "$VM_APP"
printf "\n VM NAMESPACE : %s \n" "$VM_NAMESPACE"
printf "\n VM Work Directory : %s \n" "$WORK_DIR"
printf "\n VM Kubernetes Service Account : %s \n" "$SERVICE_ACCOUNT"
printf "\n VM Istio Cluster Network : %s \n" "$CLUSTER_NETWORK"
printf "\n VM Istio Network : %s \n" "$VM_NETWORK"
printf "\n VM Istio Cluster Name : %s \n" "$CLUSTER"
printf "\n ======================================================== \n"