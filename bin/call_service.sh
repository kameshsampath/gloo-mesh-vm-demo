#!/bin/bash

set -eu
set -o pipefail

trap '{ echo "" ; exit 1; }' INT

if [ ! -f "$DEMO_HOME/work/svc.url" ];
then
 export INGRESS_GATEWAY_IP=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}')
 export SVC_URL="${INGRESS_GATEWAY_IP}/customer"
 tee "$DEMO_HOME/work/svc.url" &>/dev/null
fi


printf "\n###################################################\n"
printf "\nCalling Service URL %s \n" "$SVC_URL"
printf "\n###################################################\n"

curl "http://$SVC_URL"

