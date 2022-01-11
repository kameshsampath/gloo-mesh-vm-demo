#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/currentEnv.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/helpers.sh"


printf "\nCreating the Workload for VM in %s\n" "${MGMT}"

envsubst < "$TUTORIAL_HOME/mesh-files/vm/workload.yaml" | kubectl --context="${MGMT}" apply -f -

printf "\nCreating the Destination for VM Service in %s\n" "${MGMT}"

envsubst < "$TUTORIAL_HOME/mesh-files/vm/destination.yaml" | kubectl --context="${MGMT}" apply -f -
