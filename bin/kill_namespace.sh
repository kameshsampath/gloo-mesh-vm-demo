#!/bin/bash

CLUSTER_NAME="$(kubectl config current-context)"

kubectl get namespace "$1" -o json | jq '.spec.finalizers=[]' > "$TUTORIAL_HOME/work/tmp.json"

TOKEN=$(kubectl get secrets -n kube-system -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='namespace-controller')].data.token}"|base64 --decode)

API_SERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.server}")

http --verify=no PUT "$API_SERVER/api/v1/namespaces/$1/finalize" "Authorization: Bearer $TOKEN" @tmp.json

rm -rf tmp.json "$TUTORIAL_HOME/work/tmp.json"