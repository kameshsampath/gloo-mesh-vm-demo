#!/bin/bash

set -eu
set -o pipefail 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

export TUTORIAL_HOME
TUTORIAL_HOME="$(realpath -m "$SCRIPT_DIR/..")"