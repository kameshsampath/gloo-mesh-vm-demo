#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/currentEnv.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/helpers.sh"

CURRENT_ACCESS_POLICY=$(kubectl --context="$MGMT" get virtualmeshes.networking.mesh.gloo.solo.io -n gloo-mesh bgc-virtual-mesh -o json | jq  -r '.spec.globalAccessPolicy')

if [ "ENABLED" == "$CURRENT_ACCESS_POLICY" ];
then
  printf "\n Purging existing Access policies..\n"
  
  # kubectl --context="${MGMT}" delete -f  "$TUTORIAL_HOME/mesh-files/policy"  || true
  
  printf "\n Global Access Policy is currently enabled, disabling it. \n"

  yq eval '.spec.globalAccessPolicy = "DISABLED"' "$TUTORIAL_HOME/mesh-files/bgc-virtual-mesh.yaml" | kubectl --context="${MGMT}" apply -f - 

else
  printf "\n Global Access Policy is currently disabled, enabling it. \n"
  yq eval '.spec.globalAccessPolicy = "ENABLED"' "$TUTORIAL_HOME/mesh-files/bgc-virtual-mesh.yaml" | kubectl --context="${MGMT}" apply -f - 
fi