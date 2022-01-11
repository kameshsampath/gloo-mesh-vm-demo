#!/bin/bash

set -eu 
set -o pipefail

printf "\n Clusters and Contexts \n"
printf "\n ======================================================== \n"
printf "\n Management Cluster Context : %s \n" "$MGMT"
printf "\n Kubernetes Cluster 1 Context : %s \n" "$CLUSTER1"
printf "\n Kubernetes Cluster 2 Context : %s \n" "$CLUSTER2"
printf "\n ======================================================== \n"