#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/currentEnv.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/helpers.sh"

if [ -z "$1" ];
then 
  echo "Please specify the context to use"
  exit 1
fi

printf "\nCreating the VM Service in %s \n" "${1}"

envsubst < "$TUTORIAL_HOME/mesh-files/vm/service.yaml" | kubectl --context="${1}" apply -f -

printf "\nCreating the VM Workload Entry in %s \n" "${1}"

envsubst < "$TUTORIAL_HOME/mesh-files/vm/workload-entry.yaml" | kubectl --context="${1}" apply -f -