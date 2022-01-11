#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$SCRIPT_DIR/currentEnv.sh"

source "$SCRIPT_DIR/helpers.sh"

kubectl --context="${MGMT}" apply -f  "$TUTORIAL_HOME/mesh-files/policy/from-vm-access-policy.yaml"