#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/currentEnv.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/helpers.sh"

kubectl --context="${MGMT}" apply -f  "$TUTORIAL_HOME/mesh-files/traffic/mobile-traffic-policy.yaml"